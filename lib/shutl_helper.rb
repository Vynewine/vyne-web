module ShutlHelper
  require 'net/http'
  require 'json'

  # Gets information of booking for a given order.
  def fetch_order_information(address)
    puts 'Shutl - Requesting order update'
    url = URI(address)

    token = shutl_token
    headers = {
        'Authorization' => "Bearer #{token}"
    }
    req = Net::HTTP::Get.new(url, headers)
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }
    JSON.parse(connection.read_body)
  end

  #Adds warehouse to shutl database
  def add_warehouse_to_shutl(warehouse)

    domain = Rails.application.config.shutl_url
    url = URI("#{domain}/stores")
    token = shutl_token
    agendas = []

    warehouse.agendas.each do |agenda|
      if agenda.opening == 0 && agenda.closing == 0
        agendas[agenda.day] = []
      else
        agendas[agenda.day] = [[agenda.shutl_opening, agenda.shutl_closing]]
      end
    end
    headers = {
        'Authorization' => "Bearer #{token}"
    }

    coordinates = nil

    unless warehouse.address.latitude.blank? || warehouse.address.latitude == 0
      coordinates = {
          :lat => warehouse.address.latitude,
          :lng => warehouse.address.longitude
      }
    end

    body = {
        :store => {
            :brand_name => warehouse.title,
            :id => warehouse.shutl_id,
            :name => "#{warehouse.title} #{warehouse.address.postcode}",
            :address_line_1 => warehouse.address.line_1,
            :address_line_2 => warehouse.address.line_2,
            :city => "London",
            :country => "GB",
            :postcode => warehouse.address.postcode,
            :coordinates => coordinates,
            :phone_number => warehouse.phone,
            :email => warehouse.email,
            :send_confirmation_email => true,
            :send_confirmation_sms => false,
            :send_store_tracking_email => false,
            :sms_phone_number => "",
            :delay_time => 0,
            :time_zone => "Europe/London",
            :opening_hours => {
                :monday => agendas[1],
                :tuesday => agendas[2],
                :wednesday => agendas[3],
                :thursday => agendas[4],
                :friday => agendas[5],
                :saturday => agendas[6],
                :sunday => agendas[0]
            }
        }
    }

    req = Net::HTTP::Post.new(url, headers)
    req.body = body.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }
    response = JSON.parse(connection.read_body)

    puts json: response['errors']

    if response['errors'].blank?
      []
    else
      map_errors(response['errors'], 'Error occurred when registering warehouse with Shutl')
    end
  end

  # Updates warehouse in shutl
  def update_shutl_warehouse(warehouse)
    puts 'Updating warehouse in shutl'
    domain = Rails.application.config.shutl_url
    url = URI("#{domain}/stores/#{warehouse.shutl_id}")
    token = shutl_token
    agendas = []
    warehouse.agendas.each do |agenda|
      if agenda.opening == 0 && agenda.closing == 0
        agendas[agenda.day] = []
      else
        agendas[agenda.day] = [[agenda.shutl_opening, agenda.shutl_closing]]
      end
    end
    headers = {
        'Authorization' => "Bearer #{token}"
    }

    coordinates = nil

    unless warehouse.address.latitude.blank? || warehouse.address.latitude == 0
      coordinates = {
          :lat => warehouse.address.latitude,
          :lng => warehouse.address.longitude
      }
    end

    body = {
        :store => {
            :brand_name => warehouse.title,
            :name => "#{warehouse.title} #{warehouse.address.postcode}",
            :address_line_1 => warehouse.address.line_1,
            :address_line_2 => warehouse.address.line_2,
            :city => 'London',
            :country => 'GB',
            :postcode => warehouse.address.postcode,
            :coordinates => coordinates,
            :phone_number => warehouse.phone,
            :email => warehouse.email,
            :send_confirmation_email => true,
            :send_confirmation_sms => false,
            :send_store_tracking_email => false,
            :sms_phone_number => "",
            :delay_time => 0,
            :time_zone => 'Europe/London',
            :opening_hours => {
                :monday => agendas[1],
                :tuesday => agendas[2],
                :wednesday => agendas[3],
                :thursday => agendas[4],
                :friday => agendas[5],
                :saturday => agendas[6],
                :sunday => agendas[0]
            }
        }
    }
    puts body.to_json
    req = Net::HTTP::Put.new(url, headers)
    req.body = body.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }

    response = JSON.parse(connection.read_body)

    if response['errors'].blank?
      []
    else
      map_errors(response['errors'], 'Error occurred when updating warehouse with Shutl')
    end
  end

  #Get warehouse details from Shutl
  def get_warehouse_info_from_shutl(warehouse)

    domain = Rails.application.config.shutl_url
    url = URI("#{domain}/stores/#{warehouse.shutl_id}")
    token = shutl_token

    headers = {
        'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Get.new(url, headers)

    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }
    shutl_response = JSON.parse(connection.read_body)

    response = {
        :errors => [],
        :data => ''
    }

    if shutl_response['errors'].blank?
      response[:data] = shutl_response['store']
    else
      response[:errors] = map_errors(shutl_response['errors'], 'Error occurred when retrieving warehouse info Shutl')
    end

    response
  end

  def cancel_booking(order_reference)
    token = shutl_token

    url = URI(Rails.application.config.shutl_url + '/bookings/' + order_reference)

    params = {
        :booking => {
            :status => 'cancelled'
        }
    }

    headers = {
        'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Put.new(url, headers)

    req.body = params.to_json
    res = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }
    puts json: res
    res
  end

  def shutl_token
    domain = Rails.application.config.shutl_url
    shutl_id = Rails.application.config.shutl_id
    shutl_secret = Rails.application.config.shutl_secret
    url = URI("#{domain}/token")
    params = {
        'client_id' => shutl_id,
        'client_secret' => shutl_secret,
        'grant_type' => 'client_credentials'
    }
    headers = {
        'Content-Type' => 'application/x-www-form-urlencoded'
    }
    reqToken = Net::HTTP::Post.new(url, headers)
    reqToken.form_data = params
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(reqToken)
    }
    response = JSON.parse(connection.read_body)
    response['access_token']
  end

  def shutl_status_to_order_status(shutl_status)
    case shutl_status.to_s.strip
      when 'confirmed', 'allocated', 'arrived'
        return 4 #pickup
      when 'collected'
        return 5 #delivery
      when 'delivered'
        return 6 #delivered
      when 'cancelled_in_advance', 'cancelled_on_arrival'
        puts 'Error: Unexpected Shutl Status Received:' + shutl_status
        return nil
      else
        return nil
    end
  end

  def map_errors(errors, default_error)

    Rails.logger.error 'Shutl Error: ' + default_error
    Rails.logger.error errors

    err = []
    err << default_error

    errors.each do |key, value|
      value.each do |error_value|
        err << key + ' - ' + error_value
      end
    end

    err
  end

end
