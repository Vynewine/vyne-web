class OrderCancellation
  include ShutlHelper
  include StripeHelper
  include UserMailer
  include CoordinateHelper

  @queue = :order_cancellations

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order Cancellations'

  def self.perform (order_id, reason)
    log 'Processing order cancellation for order id: ' + order_id.to_s

    order = Order.find(order_id)

    unless order.charge_id.blank? || order.charge_id == 'Admin'
      log 'Refunding any charges associated with the order'
      #TODO: Move this to Stripe Helper
      stripe_charge = order.charge_id
      Stripe.api_key = Rails.application.config.stripe_key
      charge = Stripe::Charge.retrieve(stripe_charge)
      refund = charge.refunds.create
      order.refund_id = refund.id
    end


    unless order.delivery_token.blank?
      if order.delivery_provider == 'google_coordinate'
        log 'Cancelling Google Coordinate delivery'
        results = CoordinateHelper.cancel_job(order)
        if results[:errors].blank?
          order.delivery_token = order.delivery_token + ' (cancelled)'
        else
          log_error results[:errors]
        end
      else
        log 'Cancelling Shutl delivery'
        cancel_booking(order.delivery_token)
      end
    end

    order.status_id = Status.statuses[:cancelled]

    order.cancellation_note = reason

    unless order.save
      log_error order.errors
    end

  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.error message }
  end

end