include CoordinateHelper

class CourierLocation
  @queue = :courier_location

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  def self.perform
    orders_in_transit = Order.where(:status => Status.statuses[:in_transit])

    if orders_in_transit.blank?
      log 'Nothing to process'
    else
      log 'processing ' + orders_in_transit.count.to_s + ' order(s).'

      orders_in_transit.each do |order|

        key = 'order:' + order.id.to_s + ':courier_location'
        cached_order_record = DataCache.get(key)

        if cached_order_record.blank?
          log 'Courier Location - order key: ' + key + ' not found or expired'
        else
          log 'Courier Location - processing for order key: ' + key
          courier_info = CoordinateHelper.get_latest_courier_position(order)

          log courier_info

          unless courier_info[:data].blank?

            unless order.delivery_courier.blank?
              if order.delivery_courier['lat'].to_s != courier_info[:data][:lat].to_s
                log '############## Courier '  + courier_info[:data][:name] + ' Location Changed ##############'
                log courier_info[:data][:lat].to_s + ' - ' + courier_info[:data][:lng].to_s
              end
            end

            order.delivery_courier = courier_info[:data]
            unless order.save
              @logger.tagged('Courier Location Job') { @logger.error order.errors }
            end
          end
        end
      end
    end
  end

  def self.log(message)
    @logger.tagged('Courier Location Job') { @logger.info message }
  end
end