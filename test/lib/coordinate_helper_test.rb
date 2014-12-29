require 'test_helper'
require 'webmock/minitest'
require 'google/api_client/client_secrets'
require 'net/http'
require 'rest-client'
require 'json'


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

    minute_ago = 60.minutes.ago.to_i * 1000

    puts minute_ago

    response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/workers/#{worker_email}/locations?startTimestampMs=#{minute_ago.to_s}&maxResults=1000",
                              {
                                  'Authorization' => "Bearer #{token}",
                                  'User-Agent' => 'Vyne Admin/1.0.0'
                              }

    results = JSON.parse(response.body)

    puts results

    results['items'].each do |item|
      puts Time.at(item['collectionTime'].to_i / 1000)
      puts item['latitude']
      puts item['longitude']
    end

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



  test 'Will get courier lates position' do
    #WebMock.disable_net_connect!

    coureir_name = 'courier1@vyne.london'
    order = orders(:order1)
    order.delivery_courier = '{"name":"' + coureir_name + '"}'
    refresh_token = '1/MvOsVqxL_EAl8fdlsXwe2B42WK2cZ3y-ZSVWvVzY9nUMEudVrK5jSpoR30zcRFq6'
    access_token = 'ya29.5ABR5SlS7rRxpGPedmocVuuh8t70IEkAw7BsnIeDeOTy_lXeFdwo_ohkJRq8g5onqC3L7Liw_gHpyg'


    stub_request(:post, 'https://accounts.google.com/o/oauth2/token').
        with(:body => {'client_id' => '662241065743-4jg7eectv71j6a4na8o327kid6m37tvd.apps.googleusercontent.com', 'client_secret' => '5kdwemy_dpS1adj3TFNvAkX2', 'grant_type' => 'refresh_token', 'refresh_token' => refresh_token},
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'accounts.google.com', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => '{ "access_token": "' + access_token +'", "expires_in": 3600}', :headers => {})

    stub_request(:get, %r{https://www.googleapis.com/coordinate/v1/teams/ZtCbuYnbGi9fTxkJtV390w/workers/#{coureir_name}.*}).
        with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer ya29.5ABR5SlS7rRxpGPedmocVuuh8t70IEkAw7BsnIeDeOTy_lXeFdwo_ohkJRq8g5onqC3L7Liw_gHpyg', 'User-Agent'=>'Vyne Admin/1.0.0'}).
        to_return(:status => 200, :body => location_response.to_json, :headers => {})

    Token.create!({
                      :key => 'google_coordinate',
                      :access_token => access_token,
                      :refresh_token => refresh_token,
                      :expires_at => '2014-12-22 19:20:05.326676'
                  })

    results = get_latest_courier_position(order)

    assert_equal(51.5199904, results[:data][:lat])

  end

  test 'Can cancel Job' do

    Token.create!({
                      :key => 'google_coordinate',
                      :access_token => "ya29.6wAxoEhWSkC72iTVMRa4WOOS0SvmD1D7aT0z9Ekj2OowueMcskO8sPgVGlS9rqCipseBY2P1n0Imww",
                      :refresh_token => "1/7qS0zkINFvC1d803uoFKVDO_Xrsi-z2VH84UxfP5lQUMEudVrK5jSpoR30zcRFq6",
                      :expires_at => "2014-12-29 19:48:02.448894"
                  })

    order = orders(:order1)
    order.delivery_token = '1883650'
    results = cancel_job(order)
    #results = get_job_status(order)
    puts results
  end

  def location_response
    {
        "kind"=>"coordinate#locationList",
        "nextPageToken"=>"1418924766155001",
        "tokenPagination"=>{
            "kind"=>"coordinate#tokenPagination",
            "nextPageToken"=>"1418924766155001"
        },
        "items"=>[
            {
                "kind"=>"coordinate#locationRecord",
                "collectionTime"=>"1418923852257",
                "latitude"=>51.5200061,
                "longitude"=>-0.1077212,
                "confidenceRadius"=>234.9836883544922
            },
            {
                "kind"=>"coordinate#locationRecord",
                "collectionTime"=>"1418923938140",
                "latitude"=>51.5199904,
                "longitude"=>-0.1077684,
                "confidenceRadius"=>24.477466583251953
            }]
    }
  end

end