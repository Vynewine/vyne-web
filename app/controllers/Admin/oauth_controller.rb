require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'json'

class Admin::OauthController < ApplicationController
  include CoordinateHelper

  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  authority_actions :callback => 'create'

  before_filter :google_client


  CREDENTIALS_FILE = Rails.root.join('config', 'client_secrets_' + Rails.env + '.json')
  GOOGLE_COORDINATE_TOKEN = 'google_coordinate'

  def google_client

    @client = Google::APIClient.new(
        :application_name => 'Vyne Admin',
        :application_version => '1.0.0'
    )

    client_secrets = Google::APIClient::ClientSecrets.load(CoordinateHelper::CREDENTIALS_FILE)

    @client.authorization = client_secrets.to_authorization
    #TODO: Scope might need access_type: 'offline'
    @client.authorization.scope = 'https://www.googleapis.com/auth/coordinate'


    @auth = @client.authorization.dup
    @auth.redirect_uri = URI.join(request.original_url, callback_admin_oauth_index_path)

  end

  def index
    @token = Token.find_by_key(CoordinateHelper::GOOGLE_COORDINATE_TOKEN)
  end

  def new
    auth = CoordinateHelper.google_auth
    redirect_to auth.authorization_uri({:approval_prompt => 'force'}).to_s, status: 303
  end

  def callback
    CoordinateHelper.fetch_access_token(params[:code])
    redirect_to admin_oauth_index_path
  end

  def show

    google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

    @client.authorization.access_token = google_token.fresh_token

    coordinate = @client.discovered_api('coordinate', 'v1')

    result = @client.execute(:api_method => coordinate.jobs.insert,
                             :parameters => {
                                 'teamId' => 'ZtCbuYnbGi9fTxkJtV390w',
                                 'address' => '8A Pickfords Wharf, Wharf Road, N1 7RJ',
                                 'lat' => 51.5312285,
                                 'lng' => -0.0970227,
                                 'title' => 'Order 18'
                             })

    require 'pp'


    render :text => result.pretty_inspect

  end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
    auth = @client.authorization.dup
    auth.redirect_uri = URI.join(request.original_url, callback_oauth_index_path) #'http://localhost:3000/oauth/callback' #to('/oauth2callback')
    #auth.update_token!(session)
    auth
    )
  end


end