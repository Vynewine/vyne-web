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

  def self.create_customer(client)

    Rails.logger.info 'Creating new Stripe Customer for Id: ' + client.id.to_s

    response = {
        :errors => [],
        :data => ''
    }

    begin
      Stripe.api_key = Rails.application.config.stripe_key
      response[:data] = Stripe::Customer.create(
          :description => 'Client Id: ' + client.id.to_s,
          :email => client.email
      )
      response
    rescue Stripe::InvalidRequestError,
        Stripe::AuthenticationError,
        Stripe::APIConnectionError,
        Stripe::StripeError => exception
      response[:errors] << handle_error(exception)
    rescue => exception
      response[:errors] << handle_error(exception)
    ensure
      unless response[:errors].blank?
        response[:errors].unshift('Error occurred while creating customer with Stripe')
      end
      return response
    end
  end

  def self.get_customer(client)

    Rails.logger.info 'Retrieving Stripe customer for Id: ' + client.id.to_s + ' with Stripe Id: ' + client.stripe_id.to_s

    response = {
        :errors => [],
        :data => ''
    }

    begin
      Stripe.api_key = Rails.application.config.stripe_key
      response[:data] = Stripe::Customer.retrieve(client.stripe_id)
    rescue Stripe::InvalidRequestError,
        Stripe::AuthenticationError,
        Stripe::APIConnectionError,
        Stripe::StripeError => exception
      response[:errors] << handle_error(exception)
    rescue => exception
      response[:errors] << handle_error(exception)
    ensure
      unless response[:errors].blank?
        response[:errors].unshift('Error occurred while retrieving customer from Stripe')
      end
      return response
    end

  end

  def self.create_card(stripe_customer, token)

    Rails.logger.info 'Creating card for Stripe Customer Id: ' + stripe_customer.id

    response = {
        :errors => [],
        :data => ''
    }

    begin
      Stripe.api_key = Rails.application.config.stripe_key
      response[:data] = stripe_customer.cards.create(:card => token)
    rescue Stripe::InvalidRequestError,
        Stripe::AuthenticationError,
        Stripe::APIConnectionError,
        Stripe::StripeError => exception
      response[:errors] << handle_error(exception)
    rescue => exception
      response[:errors] << handle_error(exception)
    ensure
      return response
    end
  end

  private

  def self.charge_card(value, stripe_card_id, stripe_customer_id)
    begin
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

  def self.handle_error(exception)
    Rails.logger.error "#{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace
    exception.message
  end
end