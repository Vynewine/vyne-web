require 'mandrill'
require 'erb'

module UserMailer

  def first_time_ordered(order)

    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :subject => 'Order Placed with Vyne. No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.london',
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
                          :content => order.address.street
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
      Rails.logger.error "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
    end
  end

  def order_notification(order)
    begin

      template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
      order_items = template.result(binding)

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :subject => 'Client: ' + order.client.name + ' - ' + order.client.email  + ' Placed Order No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.london',
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
                          :content => order.address.street
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
      Rails.logger.error "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
    end
  end

  def order_receipt(order)

    begin

      url_opt = Rails.application.config.action_mailer.default_url_options

      order_link = URI::HTTP.build({
                                       :scheme => url_opt[:scheme],
                                       :host => url_opt[:host],
                                       :port => url_opt[:port],
                                       :path => '/orders/' + order.id.to_s
                                   })

      if order.payment.brand == 3 # American Express
        cardNumber = '**** ****** ' + order.payment.number
      else
        cardNumber = '**** **** **** ' + order.payment.number
      end

      wine1 = order.order_items[0].wine
      wine1_name = "#{wine1.name} #{wine1.txt_vintage}, #{wine1.producer.name}, (#{order.order_items[0].category.name})"


      unless order.order_items[1].blank?
        wine2 = order.order_items[1].wine
        wine2_name = "#{wine2.name} #{wine2.txt_vintage}, #{wine2.producer.name}, (#{order.order_items[1].category.name})"
      end

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'receipt-2tftochv1'
      message = {
          :subject => 'Your Receipt. Order No: ' + order.id.to_s,
          :from_email => 'checkout@vyne.london',
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
                          :content => order.address.street
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
                          :content => '£' + order.total_price.to_s
                      },
                      {
                          :name => 'CUSTOMERCARD',
                          :content => cardNumber
                      },
                      {
                          :name => 'FULLWINE1NAME',
                          :content => wine1_name
                      },
                      {
                          :name => 'FULLWINE2NAME',
                          :content => wine2_name
                      }
                  ]
              }
          ]

      }


      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      Rails.logger.error "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
    rescue => exception
      message = "Error occurred while sending email order_receipt: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
    end
  end

  def merchant_order_confirmation(order)
    begin

      wine1 = order.order_items[0].wine
      inventory_item1 = Inventory.where(wine: wine1, warehouse: order.warehouse).take
      wine1_name = "1x #{wine1.name} #{wine1.txt_vintage}, #{wine1.producer.name}"
      wine1_name += wine1.region.blank? ? '' : ', ' + wine1.region.name
      wine1_name += ", #{order.warehouse.title}, ID: #{inventory_item1.vendor_sku}, (£#{order.order_items[0].cost})"


      unless order.order_items[1].blank?
        wine2 = order.order_items[1].wine
        inventory_item2 = Inventory.where(wine: wine2, warehouse: order.warehouse).take
        wine2_name = "1x #{wine2.name} #{wine2.txt_vintage}, #{wine2.producer.name}"
        wine2_name += wine2.region.blank? ? '' : ', ' + wine2.region.name
        wine2_name += ", #{order.warehouse.title}, ID: #{inventory_item2.vendor_sku}, (£#{order.order_items[1].cost})"
      end

      shutl_reference = order.delivery_token

      pickup_start_time = 'unknown'
      pickup_finish_time = 'unknown'
      unless order.delivery_quote.blank?
        pickup_start_time = Time.parse(order.delivery_quote['pickup_start']).strftime("%d/%m/%Y - %H:%M")
        pickup_finish_time = Time.parse(order.delivery_quote['pickup_finish']).strftime("%d/%m/%Y - %H:%M")
      end


      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'merchant-order-confirmation-5tmsmov1'
      message = {
          :subject => 'Vyne Order No: ' + order.id.to_s,
          :from_email => 'merchant-order@vyne.london',
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
                          :name => 'WINE1MERCHANT',
                          :content => wine1_name
                      },
                      {
                          :name => 'WINE2MERCHANT',
                          :content => wine2_name
                      },
                      {
                          :name => 'SHUTLREFNO',
                          :content => shutl_reference
                      },
                      {
                          :name => 'PICKUPSTART',
                          :content => pickup_start_time
                      },
                      {
                          :name => 'PICKUPFINISH',
                          :content => pickup_finish_time
                      }
                  ]
              }
          ]

      }


      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      Rails.logger.error "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
      Rails.logger.error exception.backtrace
    end
  end

  def order_at_your_desk(email)

    mandrill = Mandrill::API.new Rails.application.config.mandrill
    template_name = 'coverage-apology-order-at-desk-1cnps'
    message = {
        :subject => 'Order wine at your desk',
        :from_email => 'comingsoon@vyne.london',
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
  rescue => exception
    message = "Error occurred while sending email order_at_your_desk: #{exception.class} - #{exception.message} - for user: #{email}"
    Rails.logger.error message
    Rails.logger.error exception.backtrace
  end

  def coming_soon_near_you(email)

    mandrill = Mandrill::API.new Rails.application.config.mandrill
    template_name = 'coverage-apology-1cpcs'
    message = {
        :subject => 'Vyne Coming Soon',
        :from_email => 'comingsoon@vyne.london',
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
  rescue => exception
    message = "Error occurred while sending email coming_soon_near_you: #{exception.class} - #{exception.message} - for user: #{email}"
    Rails.logger.error message
    Rails.logger.error exception.backtrace
  end
end