require 'mandrill'

class AccountMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  def reset_password_instructions(record, token, opts={})

    begin

      log 'Sending reset password email for: ' + record.email

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
      log_error "A mandrill error occurred: #{e.class} - #{e.message}"
      # raise
      #TODO: This needs to go to Sentry!!!
    rescue Exception => e
      log_error "Failure sending password reset email: #{e.message}"
    end
  end

  def log(message)
    @logger = Logging.logger['AccountMailer']
    @logger.info message
  end

  def log_error(message)
    @logger = Logging.logger['AccountMailer']
    @logger.error message
  end
end