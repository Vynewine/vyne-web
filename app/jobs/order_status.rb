class OrderStatus
  @queue = :order_status

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

  def self.perform
    orders_in_process = Order.where(:status => [Status.statuses[:pickup], Status.statuses[:in_transit]], :delivery_provider => Order.delivery_types[:google_coordinate]).count

    if orders_in_process > 0
      jobs = CoordinateHelper.get_jobs_status

      if jobs[:errors].blank?

        jobs[:data].each do |job|
          order = Order.find_by(delivery_token: job[:id])
          if order.blank?
            log 'Order with for job id: ' + job[:id].to_s + ' not found.'
          else
            log 'Processing order with job id ' + job[:id].to_s
            status = CoordinateHelper.coordinate_status_to_order_status(job[:progress])
            unless status.blank?
              log 'New order status: ' + status.to_s
              order.status_id = status
            end
            unless job[:assignee].blank?
              courier = order.delivery_courier

              if courier.blank?
                courier = {:name => job[:assignee]}
              else
                courier[:name] = job[:assignee]
              end
              order.delivery_courier = courier
            end

            if order.save
              log 'Successfully saved order'
            else
              log 'Failed to process orders status update: ' + order.errors.join(', ')
            end
          end
        end

        log 'Successfully updated status for ' + orders_in_process.to_s + ' orders.'
      else
        log 'Failed to process orders status update: ' + jobs[:errors].join(', ')
      end
    else
      log 'Nothing to process'
    end
  end

  def self.log(message)
    @logger.tagged('Order Status Job') { @logger.info message }
  end
end