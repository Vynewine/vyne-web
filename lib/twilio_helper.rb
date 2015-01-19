module TwilioHelper

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Twilio Helper'

  def self.order_receipt(order_id)

    log 'Sending order receipt SMS for order id ' + order_id.to_s

    begin
      order = Order.find(order_id)

      log 'To number: ' + order.client.mobile

      account_sid = Rails.application.config.twilio_account_sid
      auth_token = Rails.application.config.twilio_auth_token
      twilio_number = Rails.application.config.twilio_number
      url_opt = Rails.application.config.action_mailer.default_url_options

      order_link = URI::HTTP.build({
                                       :scheme => url_opt[:scheme],
                                       :host => url_opt[:host],
                                       :port => url_opt[:port],
                                       :path => '/orders/' + order.id.to_s
                                   })

      @client = Twilio::REST::Client.new account_sid, auth_token

      message = @client.account.messages.create(
          :body => 'Your Vyne order has been advised. Please review it here: ' + order_link.to_s,
          :to => order.client.mobile,
          :from => twilio_number
      )

    rescue Twilio::REST::RequestError => exception
      log_error exception.message
      raise
    rescue Exception => exception
      message = "Error occurred while sending sms notification: #{exception.class} - #{exception.message} - for order: #{order_id.to_s}"
      log_error message
      log_error exception.backtrace
      raise
    end
  end

  def self.order_cancellation(order_id)

    log 'Sending order cancellation SMS for order id ' + order_id.to_s

    begin
      order = Order.find(order_id)

      log 'To number: ' + order.client.mobile

      account_sid = Rails.application.config.twilio_account_sid
      auth_token = Rails.application.config.twilio_auth_token
      twilio_number = Rails.application.config.twilio_number
      url_opt = Rails.application.config.action_mailer.default_url_options

      order_link = URI::HTTP.build({
                                       :scheme => url_opt[:scheme],
                                       :host => url_opt[:host],
                                       :port => url_opt[:port],
                                       :path => '/shop/mywines'
                                   })

      @client = Twilio::REST::Client.new account_sid, auth_token

      message = @client.account.messages.create(
          :body => 'Your Vyne order number ' +  order.id.to_s + ' has been cancelled. You can view it here: ' + order_link.to_s,
          :to => order.client.mobile,
          :from => twilio_number
      )

    rescue Twilio::REST::RequestError => exception
      log_error exception.message
      raise
    rescue Exception => exception
      message = "Error occurred while sending sms notification: #{exception.class} - #{exception.message} - for order: #{order_id.to_s}"
      log_error message
      log_error exception.backtrace
      raise
    end
  end

  def self.order_in_transit(order_id)

    log 'Sending order in transit SMS for order id ' + order_id.to_s

    begin
      order = Order.find(order_id)

      log 'To number: ' + order.client.mobile

      account_sid = Rails.application.config.twilio_account_sid
      auth_token = Rails.application.config.twilio_auth_token
      twilio_number = Rails.application.config.twilio_number
      url_opt = Rails.application.config.action_mailer.default_url_options

      order_link = URI::HTTP.build({
                                       :scheme => url_opt[:scheme],
                                       :host => url_opt[:host],
                                       :port => url_opt[:port],
                                       :path => '/orders/' + order.id.to_s
                                   })

      @client = Twilio::REST::Client.new account_sid, auth_token

      message = @client.account.messages.create(
          :body => 'Your wine is in its way. Please be available to collect from our courier. Track progress here: ' + order_link.to_s,
          :to => order.client.mobile,
          :from => twilio_number
      )

    rescue Twilio::REST::RequestError => exception
      log_error exception.message
      raise
    rescue Exception => exception
      message = "Error occurred while sending in-transit sms notification: #{exception.class} - #{exception.message} - for order: #{order_id.to_s}"
      log_error message
      log_error exception.backtrace
      raise
    end
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.error message }
  end
end