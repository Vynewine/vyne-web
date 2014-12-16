module ShutlHelper
  require 'net/http'
  require 'json'

  # Requests quotes:
  def shutl_quotes(order)

    token = shutl_token

    domain = Rails.application.config.shutl_url

    url = URI("#{domain}/quote_collections")

    puts json: url

    basket_value = (order.total_wine_cost * 100).to_i

    products = []

    order.order_items.each do |item|
      products << {
          :id => "wine_#{item.wine.id}",
          :name => 'Bottle of wine',
          :description => 'Bottle of wine',
          :url => "http://127.0.0.1/admin/wines/#{item.wine.id}",
          :length => 20,
          :width => 15,
          :height => 10,
          :weight => 1,
          :quantity => 1,
          :price => (item.cost*100).to_i
      }
    end

    params = {
        :quote_collection => {
            :channel => 'mobile',
            :page => 'checkout',
            :session_id => 'vyne_session_' + order.id.to_s,
            :basket_value => basket_value,
            :delivery_location => {
                :address => {
                    :name => order.client.name,
                    :line_1 => order.address.line_1,
                    :line_2 => order.address.line_2,
                    :company_name => order.address.company_name,
                    :postcode => order.address.postcode,
                    :city => "London",
                    :country => "GB"
                },
                :contact => {
                    :name => order.client.name,
                    :email => order.client.email,
                    :phone => order.client.mobile
                }
            },
            :vehicle => 'bicycle',
            #:products => products
        }
    }

    if order.warehouse.registered_with_shutl
      params[:quote_collection][:pickup_store_id] = order.warehouse.shutl_id
    else
      params[:quote_collection][:pickup_location] = {
          :address => {
              :name => order.warehouse.title,
              :line_1 => order.warehouse.address.line,
              :postcode => order.warehouse.address.postcode,
              :city => "London",
              :country => "GB"
          },
          :contact => {
              :name => order.warehouse.title,
              :email => order.warehouse.email,
              :phone => order.warehouse.phone
          }
      }
    end

    Rails.logger.info params

    headers = {
        'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(url, headers)
    # req.form_data = params
    req.body = params.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }

    connection.read_body

  end

  def shutl_book(quote, order)

    token = shutl_token

    domain = Rails.application.config.shutl_url
    url = URI("#{domain}/bookings")

    params = {
        :booking => {
            :quote_id => quote,
            :merchant_booking_reference => "order_#{order.id}"
        }
    }

    Rails.logger.info params

    headers = {
        'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(url, headers)
    req.body = params.to_json
    res = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
      http.request(req)
    }

    res
  end

  # Gets information of booking for a given order.
  def fetch_order_information(address)

    Rails.logger.info 'Requesting Booking Info update form Shutl'

    response = {
        :errors => [],
        :data => ''
    }

    begin
      url = URI(address)
      token = shutl_token
      headers = {
          'Authorization' => "Bearer #{token}"
      }
      req = Net::HTTP::Get.new(url, headers)
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
        http.request(req)
      }
      response[:data] = JSON.parse(connection.read_body)

    rescue => exception
      message = "Error occurred while retrieving Booking information from Shutl: #{exception.class} - #{exception.message}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
      response[:errors] << message
    ensure
      return response
    end
  end

  def add_warehouse_to_shutl(warehouse)

    Rails.logger.info 'Registering warehouse with Shutl'

    response = {
        :errors => []
    }

    begin
      domain = Rails.application.config.shutl_url
      url = URI("#{domain}/stores")
      token = shutl_token

      headers = {
          'Authorization' => "Bearer #{token}"
      }

      body = get_store_body(warehouse)

      req = Net::HTTP::Post.new(url, headers)
      req.body = body.to_json
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
        http.request(req)
      }

      shutl_response = JSON.parse(connection.read_body)

      Rails.logger.info shutl_response

      unless shutl_response['errors'].blank?
        response[:errors] = map_errors(shutl_response['errors'], 'Error occurred when registering warehouse with Shutl')
      end

    rescue => exception
      message = "Error occurred while registering warehouse with Shutl: #{exception.class} - #{exception.message}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
      response[:errors] << message
    ensure
      return response
    end
  end

  def update_shutl_warehouse(warehouse)

    Rails.logger.info 'Updating warehouse ' + warehouse.shutl_id + ' with Shutl'

    response = {
        :errors => []
    }

    begin
      domain = Rails.application.config.shutl_url
      url = URI("#{domain}/stores/#{warehouse.shutl_id}")
      token = shutl_token

      headers = {
          'Authorization' => "Bearer #{token}"
      }

      body = get_store_body(warehouse)

      req = Net::HTTP::Put.new(url, headers)
      req.body = body.to_json
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https') { |http|
        http.request(req)
      }

      shutl_response = JSON.parse(connection.read_body)

      Rails.logger.info shutl_response

      unless shutl_response['errors'].blank?
        response[:errors] = map_errors(shutl_response['errors'], 'Error occurred when updating warehouse with Shutl')
      end

    rescue => exception
      message = "Error occurred while updating warehouse with Shutl: #{exception.class} - #{exception.message}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
      response[:errors] << message
    ensure
      return response
    end
  end

  def get_warehouse_info_from_shutl(warehouse)

    Rails.logger.info 'Retrieving warehouse ' + warehouse.id.to_s + ' information from Shutl'

    response = {
        :errors => [],
        :data => ''
    }

    begin
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

      Rails.logger.info shutl_response

      if shutl_response['errors'].blank?
        response[:data] = shutl_response['store']
      else
        response[:errors] = map_errors(shutl_response['errors'], 'Error occurred when retrieving warehouse info Shutl')
      end

    rescue => exception
      message = "Error occurred while retrieving warehouse info from Shutl: #{exception.class} - #{exception.message}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
      response[:errors] << message
    ensure
      return response
    end
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

  private

  def shutl_status_to_order_status(shutl_status)
    case shutl_status.to_s.strip
      when 'confirmed', 'allocated', 'arrived'
        return Status.statuses[:pickup]
      when 'collected'
        return Status.statuses[:in_transit]
      when 'delivered'
        return Status.statuses[:delivered]
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

  def get_store_body(warehouse)

    agendas = []
    warehouse.agendas.each do |agenda|
      if agenda.opening == 0 && agenda.closing == 0
        agendas[agenda.day] = []
      else
        agendas[agenda.day] = [[agenda.shutl_opening, agenda.shutl_closing]]
      end
    end

    coordinates = nil

    unless warehouse.address.latitude.blank? || warehouse.address.latitude == 0
      coordinates = {
          :lat => warehouse.address.latitude,
          :lng => warehouse.address.longitude
      }
    end

    body = {
        :store => {
            :id => warehouse.shutl_id,
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

    Rails.logger.info body

    body

  end

end
