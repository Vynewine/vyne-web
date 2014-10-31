class HooksController < ApplicationController
  include ShutlHelper
  protect_from_forgery :except => [:updateorder]

  def updateorder
    puts 'Hook from Shuttle received with params: ' + params.to_s
    notification = params[:notification]
    token = ''
    if notification[:type] == 'booking_update'
      token = notification[:shutl_booking_reference]
    end

    if token.blank?
      puts 'Token or URI not present'
    else
      uri = Rails.application.config.shutl_url + '/bookings/' + token
      puts "Updating order for token: #{token}"
      order = Order.find_by(:delivery_token => token)
      if order.blank?
        puts "Couldn't find order for token: #{token}"
      else
        puts "Order found - id = #{order.id}"
        response = fetch_order_information(uri)
        order.delivery_status = response
        order.save
      end
    end
    render :text => 'OK'
  end
end