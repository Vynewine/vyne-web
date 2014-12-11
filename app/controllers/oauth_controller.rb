require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'

class OauthController < ApplicationController
  before_filter :google_client

  #path = File.join(Rails.root, "config", "user_config.yml")

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


    @auth = @client.authorization.dup
    @auth.redirect_uri = URI.join(request.original_url, callback_oauth_index_path)

  end

  def index
    redirect_to @auth.authorization_uri({ :approval_prompt => 'force' }).to_s, status: 303
  end


  def callback

    @auth.code = params[:code]
    @auth.fetch_access_token!

    unless @auth.access_token.blank?

      google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

      google_token.access_token = @auth.access_token
      google_token.refresh_token = @auth.refresh_token
      google_token.expires_at = Time.at(@auth.expires_at).to_datetime
      google_token.save
    end

    puts 'access_token'
    puts @auth.access_token
    puts 'refresh_token'
    puts @auth.refresh_token
    puts 'expires_in'
    puts @auth.expires_in
    puts 'issued_at'
    puts @auth.issued_at

    puts json: @auth

    coordinate = @client.discovered_api('coordinate', 'v1')

    result = @client.execute(:api_method => coordinate.jobs.insert,
                                :parameters => {
                                    'teamId' => 'ZtCbuYnbGi9fTxkJtV390w',
                                    'address' => '8A Pickfords Wharf, Wharf Road, N1 7RJ',
                                    'lat' => 51.5312285,
                                    'lng' => -0.0970227,
                                    'title' => 'Order 14'
                                },
                                :authorization => @auth)


    puts json: result

    render :text => params.to_s

  end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
    auth = @client.authorization.dup
    auth.redirect_uri =  URI.join(request.original_url, callback_oauth_index_path)  #'http://localhost:3000/oauth/callback' #to('/oauth2callback')
    #auth.update_token!(session)
    auth
    )
  end


end