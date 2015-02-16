class OrderSmsNotification

  @queue = :order_notifications

  @logger = Logging.logger['OrderSmsNotificationJob']

  def self.perform (order_id, notification_name)
    log "Processing order SMS notification job: #{notification_name} - for order id: #{order_id.to_s}"
    TwilioHelper.send(notification_name, order_id)
  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end

end