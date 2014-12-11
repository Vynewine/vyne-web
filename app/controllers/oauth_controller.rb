require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'

class OauthController < ApplicationController

  #path = File.join(Rails.root, "config", "user_config.yml")

  def index


    prepare_client

    #render :text => 'OK'
    redirect_to user_credentials.authorization_uri({ :approval_prompt => 'force' }).to_s, status: 303
  end

  def prepare_client
    @client = Google::APIClient.new(:application_name => 'Ruby Calendar sample',
                                   :application_version => '1.0.0')

    path = File.join(Rails.root, 'config', 'client_secrets_' + Rails.env + '.json')

    client_secrets = Google::APIClient::ClientSecrets.load(path)

    @client.authorization = client_secrets.to_authorization
    @client.authorization.scope = 'https://www.googleapis.com/auth/coordinate'


  end

  def callback

    prepare_client

    user_credentials.code = params[:code]
    user_credentials.fetch_access_token!

    puts 'access_token'
    puts user_credentials.access_token
    puts 'refresh_token'
    puts user_credentials.refresh_token
    puts 'expires_in'
    puts user_credentials.expires_in
    puts 'issued_at'
    puts user_credentials.issued_at

    puts json: user_credentials

    coordinate = @client.discovered_api('coordinate', 'v1')

    result = @client.execute(:api_method => coordinate.jobs.insert,
                                :parameters => {
                                    'teamId' => 'ZtCbuYnbGi9fTxkJtV390w',
                                    'address' => '8A Pickfords Wharf, Wharf Road, N1 7RJ',
                                    'lat' => 51.5312285,
                                    'lng' => -0.0970227,
                                    'title' => 'Order 13'
                                },
                                :authorization => user_credentials)


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