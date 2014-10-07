require 'mandrill'

module UserMailer
  def first_time_ordered user

    begin
      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = "thanks-buy-first-bottle"
      message = {
          :to => [
              {
                  :email => user.email,
                  :name => "Recipient1"
              }
          ],
          :merge_vars => [
              {
                  :rcpt => user.email,
                  :vars => [
                      {
                          :name => "NAME",
                          :content => user.name
                      }
                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error, Excon::Errors::SocketError => e
      # Mandrill errors are thrown as exceptions
      message = "A mandrill error occurred: #{e.class} - #{e.message} - for user: #{user.email}"
      puts message
      Rails.logger.error message
      #raise - probably don't want to raise if third party service is down.
    end
  end
end