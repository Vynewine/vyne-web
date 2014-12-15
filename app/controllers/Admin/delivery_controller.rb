class Admin::DeliveryController < ApplicationController
  include ShutlHelper
  include CoordinateHelper

  def update
    order = Order.find(params[:id])

    if order.delivery_provider == Order.delivery_types[:google_coordinate]
      response = fetch_google_coordinate_job_info(order)
    elsif order.delivery_provider == Order.delivery_types[:shutl]
      response = fetch_shutl_delivery_info(order)
    end


    if response.blank?
      order.save
      render json: response, status: :ok
    else
      render json: response, status: 500
    end
  end

  def fetch_shutl_delivery_info(order)
    response = fetch_order_information(Rails.application.config.shutl_url + '/bookings/' + order.delivery_token)

    if response[:errors].blank?
      data = response[:data]
      if !data['booking'].nil? && data['booking']['reference'] == order.delivery_token
        Rails.logger.info data
        order.delivery_status = data
        unless data['booking']['booking_status'].blank?
          status = data['booking']['booking_status']
          unless status.blank?
            new_order_status = shutl_status_to_order_status(status)
            unless new_order_status.blank?
              order.status_id = new_order_status
            end
          end
        end
      end
      nil
    else
      Rails.logger.error response[:errors]
      response[:errors]
    end
  end

  def fetch_google_coordinate_job_info(order)
    response = get_job_status(order)

    puts response

    order.delivery_status = response

    return nil
  end
end