require 'json'

class ShopController < ApplicationController
  include UserMailer
  include StripeHelper
  include GcmHelper

  before_action :authenticate_user!, :except => [:new, :create]
  authorize_actions_for UserAuthorizer, :except => [:new, :create] # Triggers user check
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :check_the_gate

  # GET /welcome
  def welcome
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/list
  def list
    @orders = Order.user_id(current_user.id).order('id desc')
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /shop/neworder
  def new
    # current_user.has_role?(:superadmin)
    @order = Order.new
    @categories = Category.all.order(:id)
    @foods = Food.all.order(:id)
    @occasions = Occasion.all.order(:id)
    @types = Type.all.order(:id)
    @preparations = Preparation.all.order(:id)

    unless params[:warehouses].blank?
      session[:warehouses] = params[:warehouses]
    end

    unless params[:selected_slot].blank?
      session[:selected_slot] = params[:selected_slot]
    end

    @warehouses = session[:warehouses]
    @selected_slot = session[:selected_slot]

  end

  # GET /orders/confirmed
  def confirmed
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /shop/create
  # POST /shop/create.json
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

      # Assign Warehouse


      warehouses = ''
      if params.has_key?(:warehouse)

        warehouse_info = JSON.parse params[:warehouse]

        @order.information = params[:warehouse]

        warehouse = Warehouse.find(warehouse_info['id'])

        if warehouse.blank?
          render json: ['Warehouse not valid'], status: :unprocessable_entity
          return
        else
          @order.warehouse = warehouse
        end

        # TODO Remove
      elsif params.has_key?(:warehouses)
        warehouses = params[:warehouses]
        @order.information = warehouses
        @order.warehouse = assign_warehouse(warehouses)
      end


      # Add Order Items with Customer Preferences
      set_customer_preferences(@order, params[:wines])

      # Set Order Status Created
      @order.status_id = Status.statuses[:created]

      # Fixed delivery price:
      @order.delivery_price = 2.5

      # Save Order
      unless @order.save
        logger.error @order.errors.full_messages().join(', ')
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


      # Check if order is realtime or a scheduled order.
      if warehouse_info.blank? || warehouse_info['schedule_date'].blank?
        @order.status_id = Status.statuses[:pending]
      else
        schedule_date = Time.parse(warehouse_info['schedule_date'] + ' ' + warehouse_info['schedule_time_from'])
      end

      if @order.save
        # Client Email
        Resque.enqueue(OrderEmailNotification, @order.id, :first_time_ordered)
        # Vyne Email
        Resque.enqueue(OrderEmailNotification, @order.id, :order_notification)

        if schedule_date.blank?
          # Merchant Email
          Resque.enqueue(OrderEmailNotification, @order.id, :merchant_order_confirmation)

          # Android Notification
          Resque.enqueue(OrderNotification, 'You have a new order.', @order.warehouse.devices.map { |device| device.registration_id })

          # Admin UI Web Notification
          WebNotificationDispatcher.publish([@order.warehouse.id], "New order placed. Id: #{@order.id}", :new_order)
        else
          Resque.enqueue_at(schedule_date, OrderFulfilment, @order.id)
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

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
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

  # DELETE /orders/1
  # DELETE /orders/1.json
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

