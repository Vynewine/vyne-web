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
          :subject => 'Order Placed with Vyne',
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
      puts "A Mandrill error occurred first_time_ordered: #{exception.class} - #{exception.message}"
    rescue Exception => exception
      message = "Error occurred while sending email first_time_ordered: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      puts message
      Rails.logger.error message
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
          :subject => 'Your Receipt',
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
      puts "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
    rescue => exception
      message = "Error occurred while sending email order_receipt: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      puts message
      puts json: exception
      Rails.logger.error message
    end
  end

  def merchant_order_confirmation(order)
    begin

      wine1 = order.order_items[0].wine
      inventory_item1 = Inventory.where(wine: wine1, warehouse: order.warehouse).take
      wine1_name = "1x #{wine1.name} #{wine1.txt_vintage}, #{wine1.producer.name}"
      wine1_name += wine1.region.blank? ? '' : ', ' + wine1.region
      wine1_name += ", #{order.warehouse.title}, ID: #{inventory_item1.vendor_sku}, (£#{order.order_items[0].cost})"


      unless order.order_items[1].blank?
        wine2 = order.order_items[1].wine
        inventory_item2 = Inventory.where(wine: wine2, warehouse: order.warehouse).take
        wine2_name = "1x #{wine2.name} #{wine2.txt_vintage}, #{wine2.producer.name}"
        wine2_name += wine2.region.blank? ? '' : ', ' + wine2.region
        wine2_name += ", #{order.warehouse.title}, ID: #{inventory_item2.vendor_sku}, (£#{order.order_items[1].cost})"
      end

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'merchant-order-confirmation-5tmsmov1'
      message = {
          :subject => 'Vyne Order No: ' + order.id.to_s,
          :from_email => 'merchant-order@vyne.london',
          :from_name => 'Vyne Merchant Team',
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
                          :content => ''
                      },
                      {
                          :name => 'PICKUPSTART',
                          :content => ''
                      },
                      {
                          :name => 'PICKUPFINISH',
                          :content => ''
                      }
                  ]
              }
          ]

      }


      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => exception
      puts "A Mandrill error occurred order_receipt: #{exception.class} - #{exception.message}"
      # rescue => exception
      #   message = "Error occurred while sending email order_receipt: #{exception.class} - #{exception.message} - for user: #{order.client.email}"
      #   puts message
      #   puts json: exception
      #   Rails.logger.error message
    end
  end
end