module GcmHelper
  def send_notification(order)

    Rails.logger.info 'Sending notification for order:'
    Rails.logger.info json: order

    registration_ids = []

    response = {
        :errors => []
    }

    unless order.warehouse.blank?
      unless order.warehouse.devices.blank?
        registration_ids = order.warehouse.devices.map { |device| device.registration_id }
      end
    end

    unless registration_ids.blank?

      Rails.logger.info 'Sending notification to devices'
      Rails.logger.info registration_ids

      gcm = GCM.new(Rails.application.config.google_gcm_public_api_key)

      options = {
          data: {
              wine_order: {order: order.id.to_s}
          },
          collapse_key: order.id.to_s
      }
      full_response = gcm.send(registration_ids, options)

      Rails.logger.info full_response

      response_body = JSON.parse (full_response)[:body]

      if response_body['failure'] > 0
        response[:errors] = response_body['results'].map { |result| result['error'] }
        Rails.logger.error response[:errors]
      end
    end

    response

  end
end