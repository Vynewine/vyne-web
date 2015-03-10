require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

module CoordinateHelper

  CREDENTIALS_FILE = Rails.root.join('config', 'client_secrets_' + Rails.env + '.json')
  GOOGLE_COORDINATE_TOKEN = 'google_coordinate'
  APP_NAME = 'Vyne Admin'
  APP_VERSION = '1.0.0'

  @logger = Logging.logger['CoordinateHelper']


  def self.google_client

    @client = Google::APIClient.new(
        :application_name => APP_NAME,
        :application_version => APP_VERSION
    )

    client_secrets = Google::APIClient::ClientSecrets.load(CREDENTIALS_FILE)

    @client.authorization = client_secrets.to_authorization
    #TODO: Scope might need access_type: 'offline'
    @client.authorization.scope = 'https://www.googleapis.com/auth/coordinate'

  end

  def self.google_auth
    google_client
    @auth = @client.authorization.dup
    @auth.redirect_uri = URI.join(request.original_url, callback_admin_oauth_index_path)
    @auth
  end

  def self.fetch_access_token(code)
    google_client
    @auth.code = code
    @auth.fetch_access_token!

    google_token = Token.find_by_key(CoordinateHelper::GOOGLE_COORDINATE_TOKEN)

    if google_token.blank?
      google_token = Token.new({:key => CoordinateHelper::GOOGLE_COORDINATE_TOKEN})
    end

    unless @auth.access_token.blank?

      google_token.access_token = @auth.access_token
      google_token.refresh_token = @auth.refresh_token
      google_token.expires_at = Time.at(@auth.expires_at).to_datetime
      google_token.save

    end

  end

  def self.schedule_job(order)

    begin

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
                                   'title' => 'Order ' + order.id.to_s + (Rails.env.production? ? '' : ' - test'),
                                   'note' => order.address.full,
                                   'customerName' => order.client.name,
                                   'customerPhoneNumber' => order.client.mobile
                               })

      body = JSON.parse(result.body)

      log body

      order.delivery_token = body['id']
      order.delivery_status = body
      order.delivery_provider = 'google_coordinate'

      WebNotificationDispatcher.publish([order.warehouse.id], "Courier Job for order: #{order.id.to_s} created", :courier_job_created, 'admin')
    rescue Exception => exception
      message = "Error occurred while scheduling Google Coordinate Job: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end
  end

  def self.cancel_job(order)
    result = {
        :errors => [],
        :data => ''
    }

    if order.delivery_token.blank?
      result[:errors] << 'Order Job ID is Missing'
      return result
    end

    begin

      google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)
      token = google_token.fresh_token
      log token
      team_id = Rails.application.config.google_coordinate_team_id

      response = RestClient.put("https://www.googleapis.com/coordinate/v1/teams/#{team_id}/jobs/#{order.delivery_token}?progress=OBSOLETE", {},
                                {
                                    'Authorization' => "Bearer #{token}",
                                    'User-Agent' => 'Vyne Admin/1.0.0'
                                })

      result[:data] = JSON.parse(response.body)

    rescue Exception => exception
      message = "Error occurred while canceling Google Coordinate Job: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
      result[:errors] << message
    ensure
      return result
    end

  end

  def self.get_job_status(order)

    result = {
        :errors => [],
        :data => ''
    }

    begin

      google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)
      token = google_token.fresh_token
      team_id = Rails.application.config.google_coordinate_team_id

      response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/jobs/#{order.delivery_token}",
                                {
                                    'Authorization' => "Bearer #{token}",
                                    'User-Agent' => 'Vyne Admin/1.0.0'
                                }

      result[:data] = JSON.parse(response.body)

    rescue Exception => exception
      message = "Error occurred while retrieving Job Status from Google Coordinate: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
      result[:errors] << message
    ensure
      return result
    end

  end

  def self.get_latest_courier_position(order)

    result = {
        :errors => [],
        :data => ''
    }

    begin

      google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)
      token = google_token.fresh_token
      team_id = Rails.application.config.google_coordinate_team_id

      courier = order.delivery_courier

      unless courier.blank?
        unless courier['name'].blank?

          worker_email = URI::encode(courier['name'])
          minute_ago = 10.minutes.ago.to_i * 1000

          response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/workers/#{worker_email}/locations?startTimestampMs=#{minute_ago.to_s}&maxResults=1000",
                                    {
                                        'Authorization' => "Bearer #{token}",
                                        'User-Agent' => 'Vyne Admin/1.0.0'
                                    }

          data = JSON.parse(response.body)

          lat = courier['lat']
          lng = courier['lng']
          collection_time = courier['collection_time']

          unless data['items'].blank?

            data['items'].each do |item|

              item_time = Time.at(item['collectionTime'].to_i / 1000)

              if collection_time.blank?
                collection_time = item_time
                lat = item['latitude']
                lng = item['longitude']
              end

              if collection_time < item_time
                collection_time = item_time
                lat = item['latitude']
                lng = item['longitude']
              end
            end
          end

          result[:data] = {
              :name => worker_email,
              :collection_time => collection_time,
              :lat => lat,
              :lng => lng
          }

        end
      end

    rescue Exception => exception
      message = "Error occurred while retrieving Courier Status: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
      result[:errors] << message
    ensure
      return result
    end

  end

  def self.get_jobs_status

    result = {
        :errors => [],
        :data => ''
    }

    begin

      google_token = Token.find_by_key(GOOGLE_COORDINATE_TOKEN)
      token = google_token.fresh_token
      team_id = Rails.application.config.google_coordinate_team_id
      minutes_ago = 30.minutes.ago.to_i * 1000

      response = RestClient.get "https://www.googleapis.com/coordinate/v1/teams/#{team_id}/jobs?minModifiedTimestampMs=#{minutes_ago.to_s}",
                                {
                                    'Authorization' => "Bearer #{token}",
                                    'User-Agent' => 'Vyne Admin/1.0.0'
                                }

      data = JSON.parse(response.body)

      result[:data] = []

      unless data['items'].blank?
        data['items'].each do |job|

          job_data = {id: job['id']}

          unless job['state'].blank?
            job_data[:assignee] = job['state']['assignee']
            job_data[:progress] = job['state']['progress']
          end

          result[:data] << job_data
        end
      end

    rescue Exception => exception
      message = "Error occurred while retrieving Jobs status: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
      result[:errors] << message
    ensure
      return result
    end
  end

  def self.coordinate_status_to_order_status(progress)
    case progress.to_s.strip
      when 'IN_PROGRESS'
        return Status.statuses[:in_transit]
      when 'COMPLETED'
        return Status.statuses[:delivered]
      else
        return nil
    end
  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end


end