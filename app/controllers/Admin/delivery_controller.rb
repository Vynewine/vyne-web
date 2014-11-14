class Admin::DeliveryController < ApplicationController
  include ShutlHelper

  def update
    order = Order.find(params[:id])
    response = fetch_order_information(Rails.application.config.shutl_url + '/bookings/' + order.delivery_token)

    if !response['booking'].nil? && response['booking']['reference'] == order.delivery_token
      order.delivery_status = response

      unless response['booking']['booking_status'].blank?
        status = response['booking']['booking_status']
        unless status.blank?
          new_order_status = shutl_status_to_order_status(status)
          unless new_order_status.blank?
            order.status_id = new_order_status
          end
        end
      end

      order.save
    end
    respond_to do |format|
        format.json { render json: response, status: :ok }
    end
  end
end