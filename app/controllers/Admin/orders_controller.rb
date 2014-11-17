class Admin::OrdersController < ApplicationController
  include ShutlHelper
  include StripeHelper
  include UserMailer

  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all.order('status_id ASC, id ASC')
  end

  # GET /orders/list.json
  def list
    require 'pp'
    puts '--------------------------'
    logger.warn "Orders request"

    puts PP.pp(params[:status], '', 80)

    @orders = Order.where(:status => params[:status])

    respond_to do |format|
      format.json
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @warehouses = Warehouse.find(@order.information['warehouses'].map { |warehouse| warehouse['id'] })
  end

  # GET /orders/new
  def new
    puts params[:controller]
    # current_user.has_role?(:superadmin)
    @order = Order.new
    logger.warn "New order"
    @statuses = Status.all
  end

  # GET /orders/confirmed
  def confirmed
  end

  # GET /orders/1/edit
  def edit
    @statuses = Status.all.order(:id)
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to [:admin, @order], notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to [:admin, @order], notice: 'Order was successfully updated.' }
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

    @order.order_items.each do |item|
      item.food_items.each do |food_item|
        food_item.destroy
      end
      item.destroy
    end

    @order.destroy
    respond_to do |format|
      format.html { redirect_to admin_orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def cancel
    @order = Order.find(params[:order_id])

    #Refund any charges associated with the order
    unless @order.charge_id.blank?
      stripe_charge = @order.charge_id
      Stripe.api_key = Rails.application.config.stripe_key
      charge = Stripe::Charge.retrieve(stripe_charge)
      puts json: charge
      puts charge.refunds
      refund = charge.refunds.create
      @order.refund_id = refund.id
    end

    #Cancel Shutl delivery if already booked
    unless @order.delivery_token.blank?
      cancel_booking(@order.delivery_token)
    end

    @order.status_id = 7

    #TODO Handle save errors
    @order.save

    respond_to do |format|
      format.html { redirect_to [:admin, @order], notice: 'Order was successfully cancelled.' }
    end
  end

  def charge
    @order = Order.find(params[:order_id])
    results = StripeHelper.charge(@order)
    if results
      respond_to do |format|
        format.html { redirect_to [:admin, @order], notice: 'Order was successfully charged.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to [:admin, @order], alert: @order.errors.full_messages().join(', ') }
      end
    end
  end

  def send_receipt
    @order = Order.find(params[:order_id])
    order_receipt(@order)
    merchant_order_confirmation(@order)

    respond_to do |format|
      format.html { redirect_to [:admin, @order], notice: 'Receipt for order sent successfully' }
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(
        :status_id,
        :client_id,
        :address_id,
        :payment_id,
        :warehouse_id,
        :advisor_id,
        :wine_id,
        :quantity,
        :delivery_token,
        :information,
        :delivery_status,
        :delivery_cost,
        address_attributes: [:id, :line_1, :postcode, :line_2, :company_name]
    )
  end
end
