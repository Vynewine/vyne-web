class Admin::OrdersController < ApplicationController
  include ShutlHelper
  include StripeHelper
  include UserMailer
  include CoordinateHelper

  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  authority_actions :finished_advice => 'update',
                    :packing_complete => 'update',
                    :refresh_all => 'update',
                    :notification => 'update',
                    :order_counts => 'read',
                    :increment_notification_count => 'update',
                    :schedule_google_coordinate => 'create'


  # GET /orders
  # GET /orders.json
  def index

    @orders = Order.includes(order_items: [{food_items: [:food, :preparation]}, :type, :occasion, :wine, :inventory]).order('id DESC').page(params[:page])


    if params[:status].blank?
      @orders = @orders.where(:status => Status.statuses[:pending])
    else
      @orders = @orders.where(:status => params[:status])
    end

    unless current_user.admin?
      @orders = @orders.where(:warehouse => current_user.warehouses)
    end

    @actionable_order_counts = Order.actionable_order_counts(current_user.warehouses, current_user.admin?)

    unless params[:status].blank?
      if params[:status] == Status.statuses[:cancelled].to_s
        session[:cancel_count] = 0
      end

      if params[:status] == Status.statuses[:payment_failed].to_s
        session[:payment_failed_count] = 0
      end
    end

    @actionable_order_counts[:cancel_count] = session[:cancel_count].blank? ? 0 : session[:cancel_count]

  end

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
    if current_user.admin?
      Resque.enqueue(OrderCancellation, params[:order_id], 'Cancelled by ' + current_user.name)
      redirect_to admin_order_path(params[:order_id]), :flash => {:notice => 'Order queued for cancellation.'}
    else
      redirect_to admin_order_path(params[:order_id]), :flash => {:notice => "You don't have rights to cancel orders."}
    end
  end

  def charge

    order = Order.find(params[:order_id])
    payment_data = order.payment
    stripe_card_id = payment_data.stripe_card_id
    stripe_customer_id = payment_data.user.stripe_id
    value = (order.total_price * 100).to_i

    results = StripeHelper.charge_card(value, stripe_card_id, stripe_customer_id)

    if results[:errors].blank? && results[:data].paid

      unless results[:data].id.blank?
        order.charge_id = results[:data].id
      end

      if order.save
        redirect_to [:admin, order], :flash => {:success => 'Order was successfully charged.'}
        return
      else
        redirect_to [:admin, order], alert: @order.errors.full_messages().join(', ')
        return
      end

    else
      redirect_to [:admin, order], alert: results[:errors].join(', ')
    end
  end

  def send_receipt
    @order = Order.find(params[:order_id])

    Resque.enqueue(OrderEmailNotification, @order.id, :order_receipt)

    respond_to do |format|
      format.html { redirect_to [:admin, @order], notice: 'Receipt for order re-sent successfully' }
    end

  end

  def finished_advice
    @order = Order.find(params[:order_id])
    @order.status_id = Status.statuses[:advised]
    @order.advisory_completed_at = Time.now.utc

    Resque.enqueue_in(5.minutes, OrderConfirmation, :order_id => @order.id, :admin => @order.client.admin?)
    Resque.enqueue(OrderEmailNotification, @order.id, :order_receipt)
    Resque.enqueue(OrderSmsNotification, @order.id, :order_receipt)

    if @order.save
      WebNotificationDispatcher.publish([@order.warehouse.id], '', :order_change)
      redirect_to admin_orders_url(:status => @order.status_id), :flash => {:notice => 'Order advised. Waiting for client to confirm.'}
    else
      redirect_to [:admin, @order], :flash => {:error => @order.errors.full_messages().join(', ')}
    end
  end

  def packing_complete
    @order = Order.find(params[:order_id])
    @order.status_id = Status.statuses[:pickup]

    if @order.save
      WebNotificationDispatcher.publish([@order.warehouse.id], '', :order_change)
      redirect_to admin_orders_url(:status => @order.status_id), :flash => {:notice => 'Packing Completed for order: ' + @order.id.to_s}
    else
      redirect_to [:admin, @order], :flash => {:error => @order.errors.full_messages().join(', ')}
    end
  end

  def order_counts
    actionable_order_counts = Order.actionable_order_counts(current_user.warehouses, current_user.admin?)
    actionable_order_counts[:cancel_count] = session[:cancel_count].blank? ? 0 : session[:cancel_count]
    render json: {success: true, actionable_order_counts: actionable_order_counts}, status: :ok
  end

  def increment_notification_count

    case params[:notification]
      when 'cancel'
        session[:cancel_count] = session[:cancel_count].blank? ? 1 : session[:cancel_count] += 1
      else
        logger.warn 'Unknown notification'
    end

    render json: {success: true}, status: :ok
  end

  def schedule_google_coordinate
    @order = Order.find(params[:order_id])
    CoordinateHelper.schedule_job(@order)
    if @order.save
      WebNotificationDispatcher.publish([@order.warehouse.id], '', :order_change)
      redirect_to admin_orders_url(:status => @order.status_id), :flash => {:notice => 'Google Coordinate Job Created'}
    else
      redirect_to [:admin, @order], :flash => {:error => @order.errors.full_messages().join(', ')}
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

  def sanitize(message)
    json = JSON.parse(message)
    json.each { |key, value| json[key] = ERB::Util.html_escape(value) }
    JSON.generate(json)
  end
end
