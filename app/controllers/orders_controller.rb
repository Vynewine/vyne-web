class OrdersController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for UserAuthorizer

  def index
    @orders = Order.find_by(client: current_user)
  end

  def show
    @order = Order.find_by(id: params[:id], client_id: current_user)
    if @order.nil?
      render :status => :forbidden, :text => 'Forbidden fruit'
    end
  end
end