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

    rescue Mandrill::Error => e
      # Mandrill errors are thrown as exceptions
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
        #TODO: This needs to go to Sentry!!!

    rescue Mandrill::Error, Excon::Errors::SocketError => e
      # Mandrill errors are thrown as exceptions
      message = "A mandrill error occurred: #{e.class} - #{e.message} - for user: #{order.client.email}"
      puts message
      Rails.logger.error message
      #raise - probably don't want to raise if third party service is down.
    end
  end

  def order_confirmation(order)

    begin
      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'NAME',
                          :content => order.client.name
                      }
                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error, Excon::Errors::SocketError => e
      # Mandrill errors are thrown as exceptions
      message = "A mandrill error occurred: #{e.class} - #{e.message} - for user: #{order.client.email}"
      puts message
      Rails.logger.error message
      #raise - probably don't want to raise if third party service is down.
    end
  end
end