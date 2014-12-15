require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

module CoordinateHelper

  CREDENTIALS_FILE = Rails.root.join('config', 'client_secrets_' + Rails.env + '.json')
  GOOGLE_COORDINATE_TOKEN = 'google_coordinate'
  APP_NAME = 'Vyne Admin'
  APP_VERSION = '1.0.0'

  def google_client

    @client = Google::APIClient.new(
        :application_name => APP_NAME,
        :application_version => APP_VERSION
    )

    client_secrets = Google::APIClient::ClientSecrets.load(CREDENTIALS_FILE)

    @client.authorization = client_secrets.to_authorization
    #TODO: Scope might need access_type: 'offline'
    @client.authorization.scope = 'https://www.googleapis.com/auth/coordinate'

  end

  def google_auth
    google_client
    @auth = @client.authorization.dup
    @auth.redirect_uri = URI.join(request.original_url, callback_admin_oauth_index_path)
    @auth
  end

  def fetch_access_token(code)
    google_client
    @auth.code = code
    @auth.fetch_access_token!

    google_token = Token.find_by_key(CoordinateHelper::GOOGLE_COORDINATE_TOKEN)

    if google_token.blank?
      google_token = Token.new({ :key => CoordinateHelper::GOOGLE_COORDINATE_TOKEN })
    end

    unless @auth.access_token.blank?

      google_token.access_token = @auth.access_token
      google_token.refresh_token = @auth.refresh_token
      google_token.expires_at = Time.at(@auth.expires_at).to_datetime
      google_token.save

    end

  end

  def schedule_job(order)

    google_client

    google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

    @client.authorization.access_token = google_token.fresh_token

    coordinate = @client.discovered_api('coordinate', 'v1')

    result = @client.execute(:api_method => coordinate.jobs.insert,
                             :parameters => {
                                 'teamId' => Rails.application.config.google_coordinate_team_id,
                                 'address' => order.address.full,
                                 'lat' => order.address.latitude,
                                 'lng' => order.address.longitude,
                                 'title' => 'Order ' + order.id.to_s,
                                 'note' => order.address.full,
                                 'customerName' => order.client.name,
                                 'customerPhoneNumber' => order.client.mobile
                             })



    Rails.logger.debug result

    body = JSON.parse(result.body)
    puts body
    puts json: body['id']
    order.delivery_token = body['id']
    order.delivery_status = body
    order.delivery_provider = 'google_coordinate'
  end

  def cancel_job(order)

  end

  def get_job_status(order)
    google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

    token = google_token.fresh_token

    team_id = Rails.application.config.google_coordinate_team_id

    response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/jobs/#{order.delivery_token}",
                              {
                                  'Authorization' => "Bearer #{token}",
                                  'User-Agent' => 'Vyne Admin/1.0.0'
                              }

    body = JSON.parse(response.body)

    return body

  end

  def get_latest_courier_position(order)

    response = {
        :errors => [],
        :data => ''
    }

    begin

      google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

      token = google_token.fresh_token

      team_id = Rails.application.config.google_coordinate_team_id

      worker_email = URI::encode('jakub@vyne.london')

      minute_ago = 10.minutes.ago.to_i * 1000

      response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/workers/#{worker_email}/locations?startTimestampMs=#{minute_ago.to_s}&maxResults=10",
                                {
                                    'Authorization' => "Bearer #{token}",
                                    'User-Agent' => 'Vyne Admin/1.0.0'
                                }

      response[:data] = JSON.parse(response.body)

    rescue => exception
      message = "Error occurred while retrieving Booking information from Shutl: #{exception.class} - #{exception.message}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
    ensure
      return response
    end


  end

end