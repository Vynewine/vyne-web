ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/test_unit'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def stub_shutl_token
    stub_request(:post, 'https://sandbox-v2.shutl.co.uk/token').
        with(:body => {'client_id' => 'HnnFB2UbMlBXdD9h4UzKVQ==', 'client_secret' => 'pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A==', 'grant_type' => 'client_credentials'},
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'sandbox-v2.shutl.co.uk', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => '{"access_token":"493nSJPSh9_jUsjJe3S59FNnAx3-jcKBjBBzCFM_BkF9ePKcmRPqf-XqwZ3GWdBc9M4ZH-mUb0Okn1e_WPKrwg","token_type":"bearer","expires_in":788939999}', :headers => {})
  end
end
