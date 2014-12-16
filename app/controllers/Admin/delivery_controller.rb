class Admin::DeliveryController < ApplicationController
  include ShutlHelper
  include CoordinateHelper

  def update
    order = Order.find(params[:id])

    if order.delivery_provider == Order.delivery_types[:google_coordinate]
      response = get_google_coordinate_job_info(order)
    elsif order.delivery_provider == Order.delivery_types[:shutl]
      response = get_shutl_delivery_info(order)
    end


    if response.blank?
      order.save
      render json: response, status: :ok
    else
      render json: response, status: 500
    end
  end

  def get_shutl_delivery_info(order)
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

  def get_google_coordinate_job_info(order)

    results = get_job_status(order)

    if results[:errors].blank?
      order.delivery_status = results[:data]
      unless results[:data]['state'].blank?
        state = results[:data]['state']

        unless state['progress'].blank?
          status = coordinate_status_to_order_status(state['progress'])
          unless status.blank?
            order.status_id = status
          end
        end

        unless state['assignee'].blank?
          courier = order.delivery_courier

          puts 'Existing Courier'
          puts json: courier

          if courier.blank?
            courier = {:name => state['assignee']}
          else
            courier[:name] = state['assignee']
          end

          order.delivery_courier = courier

          puts 'Updated Courier'
          puts json: courier
        end
      end
      nil
    else
      results[:errors]
    end
  end
end