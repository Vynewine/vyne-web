class OrdersController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for UserAuthorizer
  authority_actions :status => 'read'

  def index
    @orders = Order.find_by(client: current_user)
  end

  def show
    @order = Order.find_by(id: params[:id], client_id: current_user)
    if @order.status_id == Status.statuses[:in_transit]
      unless @order.delivery_status['booking'].blank? ||
          @order.delivery_status['booking']['estimates'].blank? ||
          @order.delivery_status['booking']['estimates']['eta'].blank?
        @estimate = @order.delivery_status['booking']['estimates']['eta']
      end
    end
    if @order.nil?
      render :status => :forbidden, :text => 'Forbidden fruit'
    end
  end

  def status
    @order = Order.find_by(id: params[:order_id], client_id: current_user)
    if @order.blank?
      render json: ['404'], status: :not_found
    else
      render :json => {
                 :status => @order.status.label,
                 :customer_lat => @order.address.latitude,
                 :customer_lng => @order.address.longitude,
                 :warehouse_lat => @order.warehouse.address.latitude,
                 :warehouse_lng => @order.warehouse.address.longitude,
      }
    end
  end
end