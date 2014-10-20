module ShutlHelper
  require 'net/http'
  require 'json'

  # ----------------------------------------------
  # Public methods

  # Gets information of booking for a given order.
  def fetch_order_information(address)
    puts 'Updating order delivery status'    
    url = URI(address)
    token = shutl_token
    headers = {
      'Authorization' => "Bearer #{token}"
    }
    req = Net::HTTP::Get.new(url, headers)
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(req)
    }
    JSON.parse(connection.read_body)
  end

  # Adds warehouse to shutl database
  def add_warehouse_to_shutl(warehouse)
      puts 'Adding warehouse to shutl'
      domain = shutl_url
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
      body = {
          :store => {
              :brand_name => warehouse.title,
              :id => warehouse.shutl_id,
              :name => "#{warehouse.title} #{warehouse.address.postcode}",
              :address_line_1 => warehouse.address.line,
              :address_line_2 => "",
              :city => "London",
              # :county_or_state => nil,
              :country => "GB",
              :postcode => warehouse.address.postcode,
              :phone_number => warehouse.phone,
              :email => warehouse.email,
              :send_confirmation_email => true,
              :send_confirmation_sms => false,
              :send_store_tracking_email => false,
              :sms_phone_number => "",
              :delay_time => 0,
              :time_zone => "Europe/London",
              :opening_hours => {
                  :monday    => agendas[1],
                  :tuesday   => agendas[2],
                  :wednesday => agendas[3],
                  :thursday  => agendas[4],
                  :friday    => agendas[5],
                  :saturday  => agendas[6],
                  :sunday    => agendas[0]
              }
          }
      }
      puts body.to_json
      req = Net::HTTP::Post.new(url, headers)
      req.body = body.to_json
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
        http.request(req)
      }
      response = JSON.parse(connection.read_body)
      puts "================================"
      puts response
      puts "================================"
      if response["errors"]
        return false
      else
        return true
      end
    end

    # Updates warehouse in shutl
    def update_shutl_warehouse(warehouse)
      puts 'Updating warehouse in shutl'
      domain = shutl_url
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
      body = {
          :store => {
              # :brand_name => warehouse.title,
              # :id => warehouse.shutl_id,
              # :name => "#{warehouse.title}",
              # :address_line_1 => warehouse.address.line,
              # :postcode => warehouse.address.postcode,
              # :phone_number => warehouse.phone,
              # :email => warehouse.email,
              :opening_hours => {
                  :monday    => agendas[1],
                  :tuesday   => agendas[2],
                  :wednesday => agendas[3],
                  :thursday  => agendas[4],
                  :friday    => agendas[5],
                  :saturday  => agendas[6],
                  :sunday    => agendas[0]
              }
          }
      }
      puts body.to_json
      req = Net::HTTP::Put.new(url, headers)
      req.body = body.to_json
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
        http.request(req)
      }
      response = JSON.parse(connection.read_body)
      puts "================================"
      puts response
      puts "================================"
      if response["errors"]
        return false
      else
        return true
      end
    end

  private

  # ----------------------------------------------
  # Shutl private methods

  def shutl_url
    "https://sandbox-v2.shutl.co.uk"
  end

  def shutl_id
    "HnnFB2UbMlBXdD9h4UzKVQ=="
    # "UOuPfVIAvP4BJWDmXdCiSw=="
  end

  def shutl_secret
    "pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A=="
    # "DAiXY/UzTM14g6PAqAHDrm/ILwkJ3fT5mnh7aT15JiPI6YLz5GYN7qLtx4Yac60PFN+rZRuZuFyi0FExri3F6w=="
  end

  def shutl_token
    domain = shutl_url
    shutlId = shutl_id
    shutlSecret = shutl_secret
    url = URI("#{domain}/token")
    params = {
      'client_id' => shutlId,
      'client_secret' => shutlSecret,
      'grant_type' => 'client_credentials'
    }
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    reqToken = Net::HTTP::Post.new(url, headers)
    reqToken.form_data = params
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(reqToken)
    }
    response = JSON.parse(connection.read_body)
    response['access_token']
  end

end
