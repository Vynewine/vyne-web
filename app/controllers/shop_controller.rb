require 'json'

class ShopController < ApplicationController
  include UserMailer
  include StripeHelper
  include GcmHelper
  layout 'application'

  before_action :authenticate_user!, :except => [:new, :create]
  authorize_actions_for UserAuthorizer, :except => [:new, :create] # Triggers user check
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :check_the_gate

  def welcome
  end

  def index
    @orders = Order.all
  end

  def list
    @orders = Order.user_id(current_user.id).order('id desc').page(params[:page])
    render layout: 'aidani'
  end

  def show
  end

  def new
    @order = Order.new
    @categories = Category.all.order(:id)
    @foods = Food.all.order(:id)
    @occasions = Occasion.all.order(:id)
    @types = Type.all.order(:id)
    @preparations = Preparation.all.order(:id)
    @warehouse = Warehouse.find(params[:warehouse_id])
    promo = nil

    @promotion = PromotionHelper.get_promotion_text(user_signed_in? ? current_user : nil, cookies[:promo_code], @warehouse)

  end

  def confirmed
  end

  def edit
  end

  def create
    logger.info 'Creating New Order'

    begin

      # Create Order
      @order = Order.new
      @order.client = current_user

      # Assign Address
      order_address = params[:address_id].to_i
      address = Address.find(order_address)
      @order.address = address

      warehouse_id = params[:warehouse_id]

      # Assign Warehouse
      warehouse = Warehouse.find(warehouse_id)

      if warehouse.blank?
        render json: ['Warehouse not valid'], status: :unprocessable_entity
        return
      else
        @order.warehouse = warehouse
      end

      slot_info = nil
      unless params[:slot_date].blank?
        slot_info = warehouse.get_delivery_block_by(Time.parse(params[:slot_date] + ' ' + params[:slot_from]))
      end

      # Add Order Items with Customer Preferences
      set_customer_preferences(@order, params[:wines])

      # Set Order Status Created
      @order.status_id = Status.statuses[:created]

      # Apply Promotions
      PromotionHelper.apply_promotion(@order)

      # Save Order
      unless @order.save
        logger.error @order.errors.full_messages.join(', ')
        render json: @order.errors, status: :unprocessable_entity
        return
      end

      # Create Stripe Customer
      payment_results = create_stripe_customer(@order)
      unless payment_results.blank?
        logger.error payment_results
        render json: payment_results, status: :unprocessable_entity
        return
      end

      schedule_date = nil

      # Check if order is realtime or a scheduled order.
      if slot_info.blank?
        @order.status_id = Status.statuses[:pending]
      else
        if slot_info[:type] == :live
          schedule_date = Time.parse(params[:slot_date] + ' ' + slot_info[:from])
        else
          # Deliveries scheduled for daytime slot are send for fulfillment 1 hour before delivery window.
          schedule_date = Time.parse(params[:slot_date] + ' ' + slot_info[:from]) - 1.hour
        end
      end

      if slot_info.blank?
        @order.information = {
            warehouse_id: warehouse_id
        }
      else
        @order.information = {
            slot_date: params[:slot_date],
            slot_from: slot_info[:from],
            slot_to: slot_info[:to],
            slot_type: slot_info[:type],
            schedule_date: schedule_date,
            warehouse_id: warehouse_id
        }
      end

      if @order.save
        # Client Email
        if slot_info.blank?
          Resque.enqueue(OrderEmailNotification, @order.id, :first_time_ordered)
        elsif slot_info[:type] == :daytime
          Resque.enqueue(OrderEmailNotification, @order.id, :ordered_daytime_slot)
        elsif slot_info[:type] == :live
          Resque.enqueue(OrderEmailNotification, @order.id, :ordered_live_slot)
        end

        # Vyne Email
        Resque.enqueue(OrderEmailNotification, @order.id, :order_notification)

        #Vyne SMS
        Resque.enqueue(OrderSmsNotification, @order.id, :admin_order_notification)

        if schedule_date.blank?
          # Merchant Email
          Resque.enqueue(OrderEmailNotification, @order.id, :merchant_order_confirmation)

          # Android Notification
          Resque.enqueue(OrderNotification, 'You have a new order.', @order.warehouse.devices.map { |device| device.registration_id })

          # Admin UI Web Notification
          WebNotificationDispatcher.publish([@order.warehouse.id], "New order placed. Id: #{@order.id}", :new_order)
        else
          # Orders made for later delivery are scheduled
          Resque.enqueue_at(schedule_date, OrderFulfilment, :order_id => @order.id)

          # Vyne Admins Web Notification
          WebNotificationDispatcher.publish([@order.warehouse.id], "New (scheduled) order placed. Id:  #{@order.id}", :new_order, 'admin')
        end

        render :json => @order.to_json
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    rescue Exception => exception
      logger.error "#{exception.class} - #{exception.message}"
      logger.error exception.backtrace
      render json: ['We\re sorry by there was a server error.', exception.message], status: :internal_server_error
    end
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :mobile, :password, :password_confirmation)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(
        # :address_id,
        :warehouse_id,
        :client_id,
        :advisor_id,
        :wine_id,
        :quantity,
        address_attributes: [:id, :line_1, :line_2, :company_name, :postcode],
    )
  end

  def assign_warehouse(warehouses)
    final_warehouse = nil
    distance = nil
    (JSON.parse warehouses)['warehouses'].each do |warehouse|
      near_warehouse = Warehouse.find_by_id(warehouse['id'])
      current_distance = warehouse['distance'].to_f
      unless near_warehouse.blank?
        if final_warehouse.blank?
          final_warehouse = near_warehouse
          distance = current_distance
        else
          if distance > current_distance
            final_warehouse = near_warehouse
            distance = current_distance
          end
        end
      end
    end
    final_warehouse
  end

  def set_customer_preferences(order, params)

    wines = JSON.parse params

    wines.each do |wine|

      unless wine.blank?
        if !wine['occasion'].blank? && wine['occasion'].to_i != 0
          occasion = Occasion.find(wine['occasion'])
        end

        if !wine['wineType'].blank? && !wine['wineType']['id'].blank? && wine['wineType']['id'].to_i != 0
          wine_type = Type.find(wine['wineType']['id'])
        end

        #TODO: Validate params, category is required.
        category = Category.find(wine['category'])

        order_item = order.order_items.new({
                                               :specific_wine => wine['specificWine'],
                                               :quantity => wine['quantity'],
                                               :category => category
                                           })

        if wine['food'].blank?
          unless occasion.blank?
            order_item.occasion = occasion
          end

          unless wine_type.nil?
            order_item.type = wine_type
          end
        else
          wine['food'].each do |food_choice|
            food = Food.find(food_choice['id'])
            preparation = Preparation.find_by_id(food_choice['preparation'])
            FoodItem.create!(:food => food, :preparation => preparation, :order_item => order_item)
          end
        end

      end
    end
  end

  def create_stripe_customer(order)

    card_id = params[:old_card].to_i
    if card_id == 0 # New card

      # Create Stripe Customer if not created
      if current_user.stripe_id.blank?

        response = StripeHelper.create_customer(order.client)

        if response[:errors].blank?
          customer = response[:data]
          current_user.stripe_id = customer.id
        else
          return response[:errors]
        end

        unless current_user.save
          return current_user.errors
        end
      else
        response = StripeHelper.get_customer(current_user)
        if response[:errors].blank?
          customer = response[:data]
        else
          return response[:errors]
        end
      end

      token = params[:stripe_token]

      # Create Card
      response = StripeHelper.create_card(customer, token)

      if response[:errors].blank?
        card = response[:data]
      else
        return response[:errors]
      end

      payment = Payment.new
      payment.user = current_user
      payment.brand = params[:new_brand]
      payment.number = params[:new_card]
      payment.stripe_card_id = card.id
    else
      payment = Payment.find_by(:id => card_id, :user => current_user)
    end

    order.payment = payment

    nil
  end
end

