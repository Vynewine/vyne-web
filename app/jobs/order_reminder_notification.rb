module OrderReminderNotification
  @queue = :order_notifications

  @logger = Logging.logger['OrderReminderNotificationJob']

  def self.perform

    pending_orders = Order.where(:status => Status.statuses[:pending])

    if pending_orders.blank?
      log 'Nothing to process'
    else
      notifications = []

      pending_orders.each do |order|
        if order.created_at < 30.seconds.ago
          notification = notifications.select { |notification| notification[:warehouse] == order.warehouse_id }.first
          if notification.blank?
            notifications << {warehouse: order.warehouse_id, order_count: 1, registration_ids: order.warehouse.devices.map { |device| device.registration_id }}
          else
            notification[:order_count] += 1
          end
        end
      end

      notifications.each do |notification|
        registration_ids = notification[:registration_ids]
        unless registration_ids.blank?
          message = 'You have ' + notification[:order_count].to_s + ' pending order(s).'
          GcmHelper.send_notification(message, registration_ids)
        end
      end

      WebNotificationDispatcher.publish(notifications.map{|notification|notification[:warehouse]}, 'You have pending order(s).', :pending_orders)

    end

  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end
end