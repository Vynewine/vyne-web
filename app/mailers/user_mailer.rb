require 'mandrill'
require 'erb'

module UserMailer

  @logger = Logging.logger['UserMailer']

  def self.first_time_ordered(order)

    log "Sending email notification to customer: #{order.client.email} for order #{order.id.to_s}"

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :subject => 'Order Placed with Vyne. No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.co.uk',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'ORDERPREFERENCES',
                          :content => order_items

                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.line_1
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      }
                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      log_error message
      log_error exception.backtrace
    end
  end

  def self.ordered_daytime_slot(order)

    log "Sending email notification ordered_daytime_slot to customer: #{order.client.email} for order #{order.id.to_s}"

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      booked_slot = nil

      unless order.order_schedule.blank?
        from = order.warehouse.local_time(order.order_schedule[:from])
        to = order.warehouse.local_time(order.order_schedule[:to])
        booked_slot = "between #{from.strftime('%l:%M %P')} and
                    #{to.strftime('%l:%M %P')} on
                    #{to.strftime('%-d/%-m/%Y')} "
      end

      if booked_slot.blank?
        log_error('Order confirmation for booked slot should have delivery information recorded.')
      end

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'slotorderplaced-2tochv1'
      message = {
          :subject => 'Order Placed with Vyne. No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.co.uk',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'ORDERPREFERENCES',
                          :content => order_items

                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.line_1
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      },
                      {
                          :name => 'bookedslot',
                          :content => booked_slot
                      },

                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      log_error message
      log_error exception.backtrace
    end
  end

  def self.ordered_live_slot(order)

    log "Sending email notification ordered_live_slot to customer: #{order.client.email} for order #{order.id.to_s}"

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      booked_slot = nil

      unless order.order_schedule.blank?
        from = order.warehouse.local_time(order.order_schedule[:from])
        to = order.warehouse.local_time(order.order_schedule[:to])
        booked_slot = "between #{from.strftime('%l:%M %P')} and
                    #{to.strftime('%l:%M %P')} on
                    #{to.strftime('%-d/%-m/%Y')} "
      end

      if booked_slot.blank?
        log_error('Order confirmation for booked slot should have delivery information recorded.')
      end

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'liveslotplaced-3tochv1'
      message = {
          :subject => 'Order Placed with Vyne. No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.co.uk',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'ORDERPREFERENCES',
                          :content => order_items

                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.line_1
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      },
                      {
                          :name => 'bookedslot',
                          :content => booked_slot
                      },

                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      log_error message
      log_error exception.backtrace
    end
  end

  def self.order_notification(order)

    log "Sending email notification to Vyne for order #{order.id.to_s}"

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :subject => 'Client: ' + order.client.name + ' - ' + order.client.email + ' Placed Order No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.co.uk',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => Rails.application.config.order_notification,
                  :name => 'Vyne Orders'
              }
          ],
          :merge_vars => [
              {
                  :rcpt => Rails.application.config.order_notification,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'ORDERPREFERENCES',
                          :content => order_items

                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.line_1
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      }
                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      log_error message
      log_error exception.backtrace
    end
  end

  def self.order_receipt(order)

    log "Sending email order receipt to customer #{order.client.email} for order #{order.id.to_s}"

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'selected_wines.erb')))
      order_items = template.result(binding)

      url_opt = Rails.application.config.action_mailer.default_url_options

      order_link = URI::HTTP.build({
                                       :scheme => url_opt[:scheme],
                                       :host => url_opt[:host],
                                       :port => url_opt[:port],
                                       :path => '/orders/' + order.id.to_s
                                   })


      if order.payment.blank?
        card_number = 'No Card Used'
      else
        if order.payment.brand == 3 # American Express
          card_number = '**** ****** ' + order.payment.number
        else
          card_number = '**** **** **** ' + order.payment.number
        end
      end



      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'receipt-2tftochv1'
      message = {
          :subject => 'Your Receipt. Order No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.co.uk',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'SHUTL_LINK',
                          :content => ''
                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.line_1
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      },
                      {
                          :name => 'ORDER_TRACKING_LINK',
                          :content => order_link.to_s
                      },
                      {
                          :name => 'VYNEORDERID',
                          :content => order.id.to_s
                      },
                      {
                          :name => 'ORDERTOTAL',
                          :content => '£' + '%.2f' % order.total_price
                      },
                      {
                          :name => 'CUSTOMERCARD',
                          :content => card_number
                      },
                      {
                          :name => 'RECEIPTWINES',
                          :content => order_items
                      }
                  ]
              }
          ]
      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email order_receipt: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      log_error message
      log_error exception.backtrace
    end
  end

  def self.merchant_order_confirmation(order)

    log "Sending email merchant order confirmation for order id #{order.id.to_s}"

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'merchant-order-confirmation-5tmsmov1'
      message = {
          :subject => 'Vyne Order No: ' + order.id.to_s,
          :from_email => 'merchant-order@vyne.co.uk',
          :from_name => 'Vyne Merchant Team',
          :to => [
              {
                  :email => order.warehouse.email,
                  :name => order.warehouse.title
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.warehouse.email,
                  :vars => [
                      {
                          :name => 'VYNEORDERID',
                          :content => order.id.to_s
                      },
                      {
                          :name => 'RECEIPTWINES',
                          :content => order_items
                      }
                  ]
              }
          ]
      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred merchant_order_confirmation: #{exception.class} - #{exception.message}"
      log_error exception.backtrace
    rescue Exception => exception
      message = "Error occurred while sending email merchant_order_confirmation: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception.backtrace
    end
  end

  def self.order_at_your_desk(email)

    mandrill = Mandrill::API.new Rails.application.config.mandrill
    template_name = 'coverage-apology-order-at-desk-1cnps-mailchimp'
    message = {
        :subject => 'Order wine at your desk',
        :from_email => 'comingsoon@vyne.co.uk',
        :from_name => 'Vyne Drinkers',
        :to => [
            {
                :email => email,
                :name => 'Vyne Drinker'
            }
        ]
    }

    mandrill.messages.send_template template_name, nil, message

  rescue Mandrill::Error => exception
    Rails.logger.error "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
  rescue Exception => exception
    message = "Error occurred while sending email order_at_your_desk: #{exception.class} - #{exception.message} - for user: #{email}"
    Rails.logger.error message
    Rails.logger.error exception.backtrace
  end

  def self.coming_soon_near_you(email)

    mandrill = Mandrill::API.new Rails.application.config.mandrill
    template_name = 'coverage-apology-order-at-desk-1cnps-mailchimp'
    message = {
        :subject => 'Vyne Coming Soon',
        :from_email => 'comingsoon@vyne.co.uk',
        :from_name => 'Vyne Drinkers',
        :to => [
            {
                :email => email,
                :name => 'Vyne Drinker'
            }
        ]
    }

    mandrill.messages.send_template template_name, nil, message

  rescue Mandrill::Error => exception
    Rails.logger.error "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
  rescue Exception => exception
    message = "Error occurred while sending email coming_soon_near_you: #{exception.class} - #{exception.message} - for user: #{email}"
    Rails.logger.error message
    Rails.logger.error exception.backtrace
  end

  def self.order_cancellation(order)

    log "Sending email order cancellation to customer #{order.client.email} for order #{order.id.to_s}"

    begin

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'cancellation-2scch'
      message = {
          :subject => 'Your Vyne Order No: ' + order.id.to_s + ' has been cancelled.',
          :from_email => 'checkout@vyne.co.uk',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.line_1
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      },
                      {
                          :name => 'VYNEORDERID',
                          :content => order.id.to_s
                      }
                  ]
              }
          ]
      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred order_cancellation: #{exception.class} - #{exception.message}"
      raise
    rescue Exception => exception
      message = "Error occurred while sending email order_cancellation: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      log_error message
      log_error exception.backtrace
      raise
    end
  end

  def self.account_registration(user)

    log "Sending account registration for user #{user.email}"

    begin

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'account-registration'
      message = {
          :subject => 'Thank you for registering with Vyne',
          :from_email => 'hello@vyne.co.uk',
          :from_name => 'Vyne Team',
          :to => [
              {
                  :email => user.email,
                  :name => user.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => user.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => user.first_name
                      },
                      {
                          :name => 'PROMOCODE',
                          :content => user.referral_code
                      }
                  ]
              }
          ]
      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      log_error "A Mandrill error occurred account_registration: #{exception.class} - #{exception.message}"
      raise
    rescue Exception => exception
      message = "Error occurred while sending email account_registration: #{exception.class} - #{exception.message} - for user: #{user.email}"
      log_error message
      log_error exception.backtrace
    end
  end

  private

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end
end