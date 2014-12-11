require 'test_helper'
require 'google/api_client/client_secrets'


class CoordinateHelperTest < ActiveSupport::TestCase
  include CoordinateHelper

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    WebMock.allow_net_connect!
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can schedule job' do
    path = File.join(Rails.root, 'config', 'client_secrets.json')
    client_secrets = Google::APIClient::ClientSecrets.load(path)


    redirect user_credentials.authorization_uri.to_s, 303


  end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
    auth = api_client.authorization.dup
    auth.redirect_uri = to('/oauth2callback')
    auth.update_token!(session)
    auth
    )
  end

end