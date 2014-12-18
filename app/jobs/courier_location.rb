include CoordinateHelper

class CourierLocation
  @queue = :courier_location

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  def self.perform
    orders_in_transit = Order.where(:status => Status.statuses[:in_transit])

    if orders_in_transit.blank?

      log 'Nothing to process'
      #Rails.logger.info 'Courier Location - Nothing to process'
    else
      log 'processing ' + orders_in_transit.count.to_s + ' order(s).'
      #Rails.logger.info 'Courier Location - processing ' + orders_in_transit.count.to_s + ' orders.'
      orders_in_transit.each do |order|

        key = 'order:' + order.id.to_s + ':courier_location'
        cached_order_record = DataCache.get(key)

        if cached_order_record.blank?
          log 'Courier Location - order key: ' + key + ' not found or expired'
        else
          log 'Courier Location - processing for order key: ' + key
          courier_info = get_latest_courier_position(order)
          unless courier_info[:data].blank?
            order.delivery_courier = courier_info[:data]
            order.save
          end
        end
      end
    end
  end

  def self.log(message)
    @logger.tagged('Courier Location Job') { @logger.info message }
  end
end