class OrderNotification

  @queue = :order_notifications

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order Notification'

  def self.perform (message, registration_ids)
    log 'Processing order notification'
    GcmHelper.send_notification(message, registration_ids)
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

end