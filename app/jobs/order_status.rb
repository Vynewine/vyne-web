include CoordinateHelper

class OrderStatus
  @queue = :order_status

  def self.perform
    orders_in_process = Order.where(:status => [Status.statuses[:pickup], Status.statuses[:in_transit]]).count

    if orders_in_process > 0
      jobs = get_jobs_status

      if jobs[:errors].blank?

        jobs[:data].each do |job|
          order = Order.find_by(delivery_token: job[:id])
          unless order.blank?
            status = coordinate_status_to_order_status(job[:progress])
            unless status.blank?
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

            unless order.save
              puts 'Failed to process orders status update: ' + order.errors.join(', ')
            end
          end
        end

        puts 'Successfully updated status for ' + orders_in_process.to_s + ' orders.'
      else
        puts 'Failed to process orders status update: ' + jobs[:errors].join(', ')
      end
    else
      puts 'Nothing to process'
    end
    puts 'Finished refreshing orders'
  end
end