module TwilioHelper

  @logger = Logging.logger['TwilioHelper']

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
          :body => 'Your Vyne order number ' + order.id.to_s + ' has been cancelled. You can view it here: ' + order_link.to_s,
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
          :body => 'Your wine is on its way. Please be available to collect from our courier. Track progress here: ' + order_link.to_s,
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

  def self.admin_order_notification(order_id)
    log 'Sending admin order notification for order id ' + order_id.to_s

    begin

      order = Order.find(order_id)

      schedule_message = ''
      unless order.order_schedule.blank?
        schedule_message = 'Delivery Window: ' +
        "#{order.order_schedule[:from].strftime('%b %d, %Y %l:%M %p')} -" +
        "#{order.order_schedule[:to].strftime('%l:%M %p')} " +
        "(Fulfillment at: #{order.order_schedule[:schedule_date].strftime('%b %d, %Y %l:%M %p')})"
      end

      account_sid = Rails.application.config.twilio_account_sid
      auth_token = Rails.application.config.twilio_auth_token
      twilio_number = Rails.application.config.twilio_number

      @client = Twilio::REST::Client.new account_sid, auth_token

      unless Rails.application.config.vyne_order_notification_number.blank?
        numbers = Rails.application.config.vyne_order_notification_number.split(',')

        numbers.each do |number|

          log 'Sending admin order notification to: ' + number

          message = @client.account.messages.create(
              :body => 'New Vyne Order! Id: ' + order_id.to_s + '. ' + schedule_message,
              :to => number,
              :from => twilio_number
          )
        end
      end

    rescue Twilio::REST::RequestError => exception
      log_error exception.message
      raise
    rescue Exception => exception
      message = "Error occurred while sending admin order notification: #{exception.class} - #{exception.message} - for order: #{order_id.to_s}"
      log_error message
      log_error exception.backtrace
      raise
    end
  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end
end