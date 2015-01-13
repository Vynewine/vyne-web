class OrderConfirmation

  @queue = :order_confirmations

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order Confirmation'

  def self.perform (order_id, admin)
    log 'Processing order confirmation for order id: ' + order_id.to_s
    order = Order.find(order_id)
    OrderHelper.confirm_order(order, admin)
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.error message }
  end

end