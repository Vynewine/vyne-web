class OrderSmsNotification

  @queue = :order_notifications

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Order SMS Notification'

  def self.perform (order_id)
    log 'Processing order SMS notification for order ' + order_id.to_s

    begin
      order = Order.find(order_id)

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

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.info message }
  end

end