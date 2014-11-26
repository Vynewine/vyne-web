require 'json'

class ShopController < ApplicationController
  include UserMailer
  include StripeHelper
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
      # Creates order:
      @order = Order.new
      @order.client = current_user

      # Manages address:
      order_address = params[:address_id].to_i
      address = Address.find(order_address)
      @order.address = address

      # Manages card details:
      card_id = params[:old_card].to_i
      if card_id == 0 # New card

        # Create Stripe Customer if not created
        if current_user.stripe_id.blank?

          response = StripeHelper.create_customer(@order.client)

          if response[:errors].blank?
            customer = response[:data]
            current_user.stripe_id = customer.id
          else
            render json: response[:errors], status: :unprocessable_entity
            return
          end

          unless current_user.save
            render json: current_user.errors, status: :unprocessable_entity
            return
          end
        else
          response = StripeHelper.get_customer(current_user)
          if response[:errors].blank?
            customer = response[:data]
          else
            render json: response[:errors], status: :unprocessable_entity
            return
          end
        end

        token = params[:stripe_token]

        response = StripeHelper.create_card(customer, token)

        if response[:errors].blank?
          card = response[:data]
        else
          render json: response[:errors], status: :unprocessable_entity
          return
        end

        payment = Payment.new
        payment.user = current_user
        payment.brand = params[:new_brand]
        payment.number = params[:new_card]
        payment.stripe_card_id = card.id
      else
        payment = Payment.find_by(:id => card_id, :user => current_user)
      end

      @order.payment = payment
      @order.status_id = 1 #pending

      warehouses = ''
      if params.has_key?(:warehouses)
        warehouses = params[:warehouses]
      end

      wines = JSON.parse params[:wines]

      @order.information = warehouses

      if @order.save
        wines.each { |wine|

          unless wine.blank?
            if !wine['occasion'].blank? && wine['occasion'].to_i != 0
              occasion = Occasion.find(wine['occasion'])
            end

            if !wine['wineType'].blank? && !wine['wineType']['id'].blank? && wine['wineType']['id'].to_i != 0
              wine_type = Type.find(wine['wineType']['id'])
            end

            #TODO: Validate params, category is required.
            category = Category.find(wine['category'])

            order_item = @order.order_items.new({
                                                    :specific_wine => wine['specificWine'],
                                                    :quantity => wine['quantity'],
                                                    :category => category,
                                                    :price => category.price
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

            unless order_item.save
              render json: order_item.errors, status: :unprocessable_entity
              return
            end
          end
        }
      else
        render json: @order.errors, status: :unprocessable_entity
        return
      end

      apply_promotions(@order)

      if @order.save

        Thread.new do
          first_time_ordered @order
          order_notification @order
        end

        render :json => @order.to_json
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    rescue => exception
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

  def apply_promotions(order)
    #Second Bottle 5 off promotion
    if order.order_items.count == 2
      order.order_items[1].price = (order.order_items[1].price - 5)
      order.order_items[1].save
    end
  end
end

