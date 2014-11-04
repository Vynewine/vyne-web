require 'mandrill'

class AccountMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  def reset_password_instructions(record, token, opts={})

    begin
      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'forgot-password-4tfphpv1'

      message = {
          :subject => 'Forgot Password Request for Vyne',
          :from_email => 'help@vyne.london',
          :from_name => 'Vyne Helpdesk',
          :to => [
              {
                  :email => record.email,
                  :name => record.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => record.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => record.first_name
                      },
                      {
                          :name => 'FORGOT_PASSWORD_URL',
                          :content => edit_password_url(record, reset_password_token: token)
                      }
                  ]
              }
          ]
      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => e
      # Mandrill errors are thrown as exceptions
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      # A mandrill error occurred: Mandrill::UnknownSubaccountError - No subaccount exists with the id 'customer-123'
      # raise
      #TODO: This needs to go to Sentry!!!
    rescue Exception => e
      puts "Shit happens: #{e}"
    end
  end
end