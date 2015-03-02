module OrderHelper

  @logger = Logging.logger['OrderHelper']


  def self.confirm_order(order, admin)

    response = {
        :errors => []
    }

    log 'Confirming order id ' + order.id.to_s

    stripe_card_id = order.payment.stripe_card_id
    stripe_customer_id = order.payment.user.stripe_id
    value = (order.total_price * 100).to_i

    if order.charge_id.blank? && order.status_id == Status.statuses[:advised]
      if admin
        order.charge_id = 'Admin'
      else
        results = StripeHelper.charge_card(value, stripe_card_id, stripe_customer_id)

        if results[:errors].blank?
          order.charge_id = results[:data].id
        else
          response[:errors] = results[:errors]
          log_error(response[:errors].join(', '))
          order.status_id = Status.statuses[:payment_failed]
          return response
        end
      end
    else
      message = "Can't charge already charged order: " + order.id.to_s
      response[:errors] << message
    end

    unless order.charge_id.blank?
      order.status_id = Status.statuses[:packing]

      Analytics.track(
          user_id: order.client.id.to_s,
          event: 'Purchase complete',
          properties: {
              revenue: order.total_price,
              order_id: order.id
          }
      )
      #TODO Need to handle errors here
      CoordinateHelper.schedule_job(order)
    end

    if order.save
      WebNotificationDispatcher.publish([order.warehouse.id], 'You have order(s) ready for packing', :packing_orders)
    else
      response[:errors] << order.errors
    end

    unless response[:errors].blank?
      log_error response[:errors]
    end

    response
  end


  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end
end