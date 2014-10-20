class HooksController < ApplicationController
  include ShutlHelper

  # JSON Payload
  # Notes and comments
  # {
  #  "notification": {
  #    "type": "booking_update",
  #    "shutl_booking_reference": "SHUTL_BOOKING_REF",
  #    "merchant_booking_reference": "MERCHANT_BOOKING_REFERENCE",
  #    "uri": "https://api.shutl.co.uk/bookings/SHUTL_BOOKING_REF"
  #  }
  # }
  def updateorder

    puts "***********************************"
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
      puts response
      # order.delivery_status = response
    end
    # puts JSON.parse(params.to_s)
    # @order = JSON.parse(params[:notification])
    # params[:]
    # @order = Order.find(params[:id])
  end

  def index
  end

end