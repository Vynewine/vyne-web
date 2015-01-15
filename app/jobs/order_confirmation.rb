class OrderConfirmation

  @queue = :order_confirmations

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order Confirmation'

  def self.perform (args)
    log 'Processing order confirmation for order id: ' + args['order_id'].to_s
    order = Order.find(args['order_id'])
    OrderHelper.confirm_order(order, args['admin'])
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.error message }
  end

end