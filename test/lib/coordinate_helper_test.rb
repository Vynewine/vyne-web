require 'test_helper'
require 'google/api_client/client_secrets'
require 'net/http'
require 'rest-client'

class CoordinateHelperTest < ActiveSupport::TestCase
  include CoordinateHelper

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    WebMock.allow_net_connect!
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can get job status' do

    Token.create!({
      :key => 'google_coordinate',
      :access_token => 'ya29.3QDkYXsI_7_CNlJ5gWxSBRgeF7bTFQWw-_uSkx2FqXodlrOd8tIvXTz5lOnceRkZKXvw6xbHm4dulQ',
      :refresh_token => '1/MvOsVqxL_EAl8fdlsXwe2B42WK2cZ3y-ZSVWvVzY9nUMEudVrK5jSpoR30zcRFq6',
      :expires_at => Time.parse('2014-12-15 11:28:00')
    })

    google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

    token = google_token.fresh_token

    team_id = Rails.application.config.google_coordinate_team_id

    response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/jobs/",
                              {
                                  'Authorization' => "Bearer #{token}",
                                  'User-Agent' => 'Vyne Admin/1.0.0'
                              }

    puts response.body

  end


  test 'Can get worket position details' do
    Token.create!({
                      :key => 'google_coordinate',
                      :access_token => 'ya29.3QDpo-AXYeE84xf-coyWwZEtZ9ItquSDXzhfcUs2wWyeco3lVFEmq15ESPsVZUfBpGT8BGPYHtoL4Q',
                      :refresh_token => '1/MvOsVqxL_EAl8fdlsXwe2B42WK2cZ3y-ZSVWvVzY9nUMEudVrK5jSpoR30zcRFq6',
                      :expires_at => Time.parse('2014-12-15 15:00')
                  })

    google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

    token = google_token.fresh_token

    puts token

    team_id = Rails.application.config.google_coordinate_team_id

    worker_email = URI::encode('jakub@vyne.london')

    minute_ago = 10.minutes.ago.to_i * 1000

    puts minute_ago

    response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/workers/#{worker_email}/locations?startTimestampMs=#{minute_ago.to_s}&maxResults=10",
                              {
                                  'Authorization' => "Bearer #{token}",
                                  'User-Agent' => 'Vyne Admin/1.0.0'
                              }

    puts JSON.parse(response.body)

  end


end