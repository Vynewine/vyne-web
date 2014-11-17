module StripeHelper
  def self.charge(order)

    payment_data = order.payment
    stripe_card_id = payment_data.stripe_card_id
    stripe_customer_id = payment_data.user.stripe_id
    value = (order.total_price * 100).to_i

    charge_details = self.charge_card(value, stripe_card_id, stripe_customer_id)

    puts json: charge_details

    if charge_details.blank?
      return false
    else
      if charge_details.paid
        order.status_id = 2 # paid
      end

      unless charge_details.id.blank?
        order.charge_id = charge_details.id
      end

      if order.save
        return true
      else
        return order.errors
      end
    end
  end

  private

  def self.charge_card(value, stripe_card_id, stripe_customer_id)
    puts 'Charging card'
    Stripe.api_key = Rails.application.config.stripe_key
    Stripe::Charge.create(
        :amount => value,
        :currency => 'gbp',
        :customer => stripe_customer_id,
        :card => stripe_card_id
    )

  rescue Stripe::CardError => e
    # Since it's a decline, Stripe::CardError will be caught
    body = e.json_body
    err = body[:error]

    puts "Status is: #{e.http_status}"
    puts "Type is: #{err[:type]}"
    puts "Code is: #{err[:code]}"
    puts "Param is: #{err[:param]}"
    puts "Message is: #{err[:message]}"
  rescue Stripe::InvalidRequestError => e
    # Invalid parameters were supplied to Stripe's API
    puts json: e
  rescue Stripe::AuthenticationError => e
    # Authentication with Stripe's API failed
    # (maybe you changed API keys recently)
    puts json: e
  rescue Stripe::APIConnectionError => e
    # Network communication with Stripe failed
    puts json: e
  rescue Stripe::StripeError => e
    # Display a very generic error to the user, and maybe send
    # yourself an email
    puts json: e
  rescue => e
    # Something else happened, completely unrelated to Stripe
    puts json: e
  end
end