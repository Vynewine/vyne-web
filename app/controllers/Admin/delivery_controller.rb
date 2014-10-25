class Admin::DeliveryController < ApplicationController
  include ShutlHelper

  def update
    order = Order.find(params[:id])
    delivery_information = fetch_order_information(Rails.application.config.shutl_url + '/bookings/' + order.delivery_token)

    if !delivery_information['booking'].nil? && delivery_information['booking']['reference'] == order.delivery_token
      order.delivery_status = delivery_information
      order.save
    end
    respond_to do |format|
        format.json { render json: delivery_information, status: :ok }
    end
  end
end