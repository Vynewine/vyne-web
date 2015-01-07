module GcmHelper

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'GCM Helper'

  def self.send_notification(message, registration_ids)

    log 'Sending notification: ' + message

    unless registration_ids.blank?

      log 'Sending notification to devices'
      log registration_ids

      gcm = GCM.new(Rails.application.config.google_gcm_public_api_key)

      options = {
          data: {
              message: message
          }
      }

      full_response = gcm.send(registration_ids, options)

      log full_response

      response_body = JSON.parse (full_response)[:body]

      if response_body['failure'] > 0
        log_error response_body['results'].map { |result| result['error'] }
      end
    end

  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.error message }
  end

end