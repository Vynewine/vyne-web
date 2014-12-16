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

  test 'Can get list of jobs' do
    Token.create!({
                      :key => 'google_coordinate',
                      :access_token => 'ya29.3gDsoMHHKhi-XxcIc-KKMXpwvo9beFPmW9D7Xq4InnqcOaaSdh86NSNzMBH5GSEmjuXMcBlXNowsvg',
                      :refresh_token => '1/MvOsVqxL_EAl8fdlsXwe2B42WK2cZ3y-ZSVWvVzY9nUMEudVrK5jSpoR30zcRFq6',
                      :expires_at => Time.parse('2014-12-16 16:00')
                  })

    google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)

    token = google_token.fresh_token

    puts token

    team_id = Rails.application.config.google_coordinate_team_id

    minute_ago = 10.minutes.ago.to_i * 1000

    puts minute_ago

    response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/jobs?minModifiedTimestampMs=#{minute_ago.to_s}",
                              {
                                  'Authorization' => "Bearer #{token}",
                                  'User-Agent' => 'Vyne Admin/1.0.0'
                              }

    puts JSON.parse(response.body)

  end

  test 'Loop through updated jobs' do
    jobs = {"kind" => "coordinate#jobList", "nextPageToken" => "1418742264270001", "items" => [{"kind" => "coordinate#job", "id" => "1848143", "state" => {"kind" => "coordinate#jobState", "assignee" => "jakub@vyne.london", "progress" => "NOT_ACCEPTED", "location" => {"kind" => "coordinate#location", "lat" => 51.5315929489491, "lng" => -0.0967426824632059, "addressLine" => ["8a Pickfords Wharf, Wharf Road, N1 7RJ"]}, "note" => ["8a Pickfords Wharf, Wharf Road, N1 7RJ"], "title" => "Order 35 - test", "customerName" => "Jakub Borys", "customerPhoneNumber" => "+44 7718225201", "customFields" => {"kind" => "coordinate#customFields"}}, "jobChange" => [{"kind" => "coordinate#jobChange", "timestamp" => "1418739135153", "state" => {"kind" => "coordinate#jobState", "assignee" => "", "progress" => "NOT_ACCEPTED", "location" => {"kind" => "coordinate#location", "lat" => 51.5315929489491, "lng" => -0.0967426824632059, "addressLine" => ["8a Pickfords Wharf, Wharf Road, N1 7RJ"]}, "note" => ["8a Pickfords Wharf, Wharf Road, N1 7RJ"], "title" => "Order 35 - test", "customerName" => "Jakub Borys", "customerPhoneNumber" => "+44 7718225201", "customFields" => {"kind" => "coordinate#customFields"}}}, {"kind" => "coordinate#jobChange", "timestamp" => "1418742264270", "state" => {"kind" => "coordinate#jobState", "assignee" => "jakub@vyne.london", "progress" => "NOT_ACCEPTED"}}]}]}

    unless jobs['items'].blank?
      jobs['items'].each do |job|
        puts job['id']
        unless job['state'].blank?
          puts job['state']['assignee']
          puts job['state']['progress']
        end
      end
    end
  end


end