class OrderEmailNotification

  @queue = :order_notifications

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order Email Notification Job'

  def self.perform (order_id, notification_name)
    log "Processing email notification job: #{notification_name} - for order id: #{order_id.to_s}"
    order = Order.find(order_id)
    UserMailer.send(notification_name, order)
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end
end