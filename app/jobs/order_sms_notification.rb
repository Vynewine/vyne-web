class OrderSmsNotification

  @queue = :order_notifications

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order SMS Notification Job'

  def self.perform (order_id, notification_name)
    log "Processing order SMS notification job: #{notification_name} - for order id: #{order_id.to_s}"
    TwilioHelper.send(notification_name, order_id)
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.info message }
  end

end