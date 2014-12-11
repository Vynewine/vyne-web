module CoordinateHelper

  CREDENTIALS_FILE = Rails.root.join('config', 'client_secrets_' + Rails.env + '.json')
  GOOGLE_COORDINATE_TOKEN = 'google_coordinate'

  def google_client

    @client = Google::APIClient.new(
        :application_name => 'Vyne Admin',
        :application_version => '1.0.0'
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

    puts json: result

  end

  def cancel_job(order)

  end
end