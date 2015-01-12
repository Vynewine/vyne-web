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

    @order = Order.find(order_id)

    #Refund any charges associated with the order
    unless @order.charge_id.blank? || @order.charge_id == 'Admin'
      #TODO: Move this to Stripe Helper
      stripe_charge = @order.charge_id
      Stripe.api_key = Rails.application.config.stripe_key
      charge = Stripe::Charge.retrieve(stripe_charge)
      puts json: charge
      puts charge.refunds
      refund = charge.refunds.create
      @order.refund_id = refund.id
    end

    #Cancel Shutl delivery if already booked
    unless @order.delivery_token.blank?
      if @order.delivery_provider == 'google_coordinate'
        cancel_job(@order)
      else
        cancel_booking(@order.delivery_token)
      end

    end

    @order.status_id = Status.statuses[:cancelled]

    @order.cancellation_note = reason

    @order.save

  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

end