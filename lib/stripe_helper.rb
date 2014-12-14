module StripeHelper

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

    Rails.logger.info 'Charging card for Stripe Card Id: ' + stripe_card_id

    response = {
        :errors => [],
        :data => ''
    }

    begin
      Stripe.api_key = Rails.application.config.stripe_key
      response[:data] = Stripe::Charge.create(
          :amount => value,
          :currency => 'gbp',
          :customer => stripe_customer_id,
          :card => stripe_card_id
      )

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

  def self.handle_error(exception)
    Rails.logger.error "#{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace
    exception.message
  end
end