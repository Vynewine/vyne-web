class HooksController < ApplicationController
  include ShutlHelper
  protect_from_forgery :except => [:updateorder]

  def updateorder
    puts 'Hook from Shuttle received with params: ' + params.to_s
    notification = params[:notification]
    if notification[:type] == "booking_update"
      uri = notification[:uri]
      token = notification[:shutl_booking_reference]
    end

    if token && uri
      puts "updating.. #{token}"
      order = Order.find_by(:delivery_token => token)
      puts "Order id = #{order.id}"
      response = fetch_order_information(uri)
      order.delivery_status = response
      order.save
      render :text => 'OK'
    end
  end

  def index
  end

end