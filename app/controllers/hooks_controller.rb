class HooksController < ApplicationController
  include ShutlHelper
  protect_from_forgery :except => [:updateorder]

  def updateorder
    notification = params[:notification]
    token = ''
    if notification[:type] == 'booking_update'
      token = notification[:shutl_booking_reference]
    end

    if token.blank?
      puts 'Token not present'
    else
      uri = Rails.application.config.shutl_url + '/bookings/' + token
      puts "Updating order for token: #{token}"
      order = Order.find_by(:delivery_token => token)
      if order.blank?
        puts "Couldn't find order for token: #{token}"
      else
        puts "Order found - id = #{order.id}"

        #TODO: This is not DRY - Repeated on DeliveryController.update
        response = fetch_order_information(uri)

        if response[:errors].blank?
          data = response[:data]

          order.delivery_status = data

          unless data['booking'].blank? || data['booking']['booking_status'].blank?
            status = data['booking']['booking_status']
            unless status.blank?
              new_order_status = shutl_status_to_order_status(status)
              unless new_order_status.blank?
                order.status_id = new_order_status
              end
            end
          end
          order.save
        end
      end
    end
    render :text => 'OK'
  end
end