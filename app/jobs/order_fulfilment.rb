class OrderFulfilment
  @queue = :order_fulfilment

  @logger = Logging.logger['OrderFulfilment']

  def self.perform (args)

    log "Processing order fulfillment for order #{args['order_id']}"

    order = Order.find(args['order_id'])

    if order.status_id == Status.statuses[:created]

      order.status_id = Status.statuses[:pending]

      if order.save
        # Merchant Email
        Resque.enqueue(OrderEmailNotification, order.id, :merchant_order_confirmation)

        # Android Notification
        Resque.enqueue(OrderNotification, 'Scheduled Order has just been processed.', order.warehouse.devices.map { |device| device.registration_id })

        # Admin UI Web Notification
        WebNotificationDispatcher.publish([order.warehouse.id], "Scheduled Order processed. Id: #{order.id}", :new_order)
      else
        log_error order.errors
      end
    else
      log "Order #{args['order_id']} not in created status"
    end

  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end
end