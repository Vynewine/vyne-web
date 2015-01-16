class OrdersController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for UserAuthorizer
  authority_actions :status => 'read',
                    :substitution_request => 'read',
                    :substitute => 'update',
                    :cancel => 'update',
                    :cancellation_request => 'read',
                    :accept => 'update'

  def index
    @orders = Order.find_by(client: current_user)
  end

  def show
    if current_user.admin?
      @order = Order.find_by(id: params[:id])
    else
      @order = Order.find_by(id: params[:id], client_id: current_user)
    end

    if @order.nil?
      render :status => :forbidden, :text => 'Forbidden fruit'
      return
    end

    if @order.status_id == Status.statuses[:in_transit]
      unless @order.delivery_status['booking'].blank? ||
          @order.delivery_status['booking']['estimates'].blank? ||
          @order.delivery_status['booking']['estimates']['eta'].blank?
        @estimate = @order.delivery_status['booking']['estimates']['eta']
      end
    end

  end

  def status
    if current_user.admin?
      @order = Order.find_by(id: params[:order_id])
    else
      @order = Order.find_by(id: params[:order_id], client_id: current_user)
    end

    seconds_since_advisory = -1

    unless @order.advisory_completed_at.blank?
      seconds_since_advisory = (Time.now.utc - @order.advisory_completed_at).seconds.to_i
    end

    if @order.blank?
      render json: ['404'], status: :not_found
    else
      render :json => {
                 :status => @order.status.label,
                 :customer_lat => @order.address.latitude,
                 :customer_lng => @order.address.longitude,
                 :warehouse_lat => @order.warehouse.address.latitude,
                 :warehouse_lng => @order.warehouse.address.longitude
             }
    end
  end

  def substitution_request
    if current_user.admin?
      @order = Order.find_by(id: params[:order_id])
    else
      @order = Order.find_by(id: params[:order_id], client_id: current_user)
    end

    if @order.blank?
      render :status => :forbidden, :text => 'Forbidden fruit'
      return
    end
  end

  def substitute

    if current_user.admin?
      @order = Order.find_by(id: params[:order_id])
    else
      @order = Order.find_by(id: params[:order_id], client_id: current_user)
    end

    if @order.blank?
      render :status => :forbidden, :text => 'Forbidden fruit'
      return
    end

    substitutions = JSON.parse params[:substitutions]

    unless substitutions.blank?
      substitutions.each do |sub|
        order_item = @order.order_items.select { |item| item.id.to_s == sub['id'].to_s }.first
        order_item.substitution_requested_at = Time.now.utc
        order_item.substitution_status = 'requested'
        order_item.substitution_request_note = sub['reason']
        order_item.save
      end
    end

    @order.status_id = Status.statuses[:pending]

    @order.save

    redirect_to order_path(@order)
  end

  def cancellation_request
    if current_user.admin?
      @order = Order.find_by(id: params[:order_id])
    else
      @order = Order.find_by(id: params[:order_id], client_id: current_user)
    end

    if @order.blank?
      render :status => :forbidden, :text => 'Forbidden fruit'
    end
  end

  def cancel

    if current_user.admin?
      @order = Order.find_by(id: params[:order_id])
    else
      @order = Order.find_by(id: params[:order_id], client_id: current_user)
    end

    if @order.blank?
      render :status => :forbidden, :text => 'Forbidden fruit'
      return
    end

    Resque.remove_delayed(OrderConfirmation, :order_id => @order.id, :admin => @order.client.admin?)
    Resque.enqueue(OrderCancellation, params[:order_id], params[:reason])
    redirect_to order_path(params[:order_id], :cancelled => 'true')
  end

  def accept
    if current_user.admin?
      @order = Order.find_by(id: params[:order_id])
    else
      @order = Order.find_by(id: params[:order_id], client_id: current_user)
    end

    if @order.blank?
      render :status => :forbidden, :text => 'Forbidden fruit'
      return
    end

    Resque.remove_delayed(OrderConfirmation, :order_id => @order.id, :admin => @order.client.admin?)
    results = OrderHelper.confirm_order(@order, @order.client.admin?)

    if results[:errors].blank?
      redirect_to order_path(@order)
    else
      @errors = results[:errors]
    end
  end
end