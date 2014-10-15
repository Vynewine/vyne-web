class Admin::AdvisorsController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  respond_to :html, :js

  def index
    @orders = Order.where.not(status_id: [5,6]) # Ignores delivered and cancelled
    @categories = Category.all
  end

  def choose
    require 'pp'
    logger.warn '--------------------------'
    logger.warn "Choice request"

    # We pass order and warehouse. Warehouse must have a keyword inside shutl's application.
    puts PP.pp("Warehouse:",'',80)
    puts PP.pp(params[:warehouse],'',80)
    order = Order.find(params[:order])
    warehouse = Warehouse.find(params[:warehouse])
    wine = Wine.find(params[:wine])
    quotes = shutl_quotes(order, warehouse, wine)
    @quotes = JSON.parse(quotes) # Hash obj

    puts PP.pp(@quotes,'',80)
    logger.warn '--------------------------'

  end

  def complete
    require 'pp'
    logger.warn '--------------------------'
    logger.warn "Complete order request"
    puts PP.pp(params,'',80)

    # return;
    warehouse = Warehouse.find(params[:warehouse])
    wine = Wine.find(params[:wine])
    inventory = Inventory.find_by(:wine_id => params[:wine], :warehouse_id => params[:warehouse])
    puts PP.pp("Warehouse:",'',80)
    puts PP.pp(params[:warehouse],'',80)
    order = Order.find(params[:order])
    order.wine = wine
    order.quantity = 1
    order.advisor_id = current_user.id
    order.warehouse_id = params[:warehouse]
    inventory.quantity = inventory.quantity - 1
    if inventory.save
      if order.save
        # Stripe
        paymentData = order.payment
        stripeToken = 'cus_4uQiP8ZhPAKXoa' # paymentData.stripe
        value = 1500 # $15.00 this time
        chargeDetails = charge_card(value, stripeToken)
        if chargeDetails.paid == true
          order.status_id = 2 # paid
          if order.save
            # Shutl
            booking_ref = shutl_book(params[:quote], order)
            unless booking_ref.nil? == true
              order.delivery = booking_ref
              order.status_id = 4 #pickup
              if order.save
                @message = 'success'
              else
                @message = "error:Couldn't save order after booking"                
              end
            else
              @message = "error:Couldn't do the booking."
            end
          end
        else
          @message = "error:The payment was not processed. #{chargeDetails.description}"
          order.status_id = 3 #payment failed
        end
      else
        @message = "error:Couldn't save order"
      end
    else
      @message = "error:Couldn't update inventory"
    end
  end

  def results
    require 'pp'
    puts '--------------------------'
    logger.warn "Search request"
    puts PP.pp(params[:keywords],'',80)
    puts PP.pp(request.request_parameters,'',80)

    # params[:categories]

    # Solr:
    @search = Wine.search do
      fulltext params[:keywords]

      # facet(:warehouse_id) do

      with(:warehouse_ids, params[:warehouses].split(","))

      unless params[:categories].nil?
        with(:price_categories, params[:categories])
      end

      # end
      # warehouse_filter = with(:warehouse_id, 1)
      # facet :warehouse_id, exclude: [warehouse_filter]
      if params[:single]
        with(:single_estate, true)
      end
      if params[:vegan]
        with(:vegan, true)
      end
      if params[:organic]
        with(:organic, true)
      end
    end
    puts PP.pp(@search.total,'',80)
    # puts PP.pp(@search.results,'',80)
    @results = @search.results
    
    # puts '--------------------------'
    # puts ' RESULTS'
    # puts '--------------------------'
    # @results.each do |wine|
      # puts '- - - - - - - - - - - - -'
      # puts PP.pp(wine.name,'',80)
      # puts PP.pp(wine.appellation,'',80)
      # puts PP.pp(wine.vintage,'',80)
      # puts PP.pp(wine.producer.country.alpha_2,'',80)
      # puts PP.pp(wine.producer.country.name,'',80)
      # puts PP.pp(wine.compositions,'',80)
      # puts PP.pp(wine.grapes,'',80)
      # puts PP.pp(wine.warehouses,'',80)
      # puts PP.pp(wine.subregion || 'none' ,'',80)
      # puts '- - - - - - - - - - - - -'
    # end
    # puts '--------------------------'

    respond_to do |format|
      format.json
    end
  end

  private

  def charge_card(value, stripeToken)
    puts "Charging card"
    Stripe.api_key = "sk_test_BQokikJOvBiI2HlWgH4olfQ2"
    Stripe::Charge.create(
      :amount   => value, 
      :currency => "gbp",
      :customer => stripeToken
    )
  end

  def shutl_url
    "https://sandbox-v2.shutl.co.uk"
    # shutlId = "UOuPfVIAvP4BJWDmXdCiSw=="
  end

  def shutl_id
    "HnnFB2UbMlBXdD9h4UzKVQ=="
  end

  def shutl_secret
    "pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A=="
    # shutlSecret = "DAiXY/UzTM14g6PAqAHDrm/ILwkJ3fT5mnh7aT15JiPI6YLz5GYN7qLtx4Yac60PFN+rZRuZuFyi0FExri3F6w=="
  end

  def shutl_token
    puts "Requesting delivery token"
    require 'net/http'
    require 'json'

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

    #**************************
    # Requests token:

    reqToken = Net::HTTP::Post.new(url, headers)
    reqToken.form_data = params
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(reqToken)
    }

    # Dummy response:
    # { 
    #   "access_token": "DUMMY_TOKEN",
    #   "token_type": "bearer",
    #   "expires_in": 999
    # }

    response = JSON.parse(connection.read_body)
    response['access_token']
    # puts response
    # puts token
  end

  def shutl_quotes(order, warehouse, wine)

    token = shutl_token

    #**************************
    # Requests quote:

    domain = shutl_url
    url = URI("#{domain}/quote_collections")
    inventory_entry = Inventory.find_by(:warehouse_id => warehouse.id, :wine_id => wine.id)
    price = inventory_entry.category.price

    params = {
      :quote_collection => {
        :channel => "pos",
        :page => "product",
        :session_id => "example123",
        :basket_value => 1999,
        # :pickup_store_id => warehouse,
        :pickup_location => {
          :address => {
            :postcode => warehouse.address.postcode
          }
        },
        :delivery_location => {
          :address => {
            :postcode => order.address.postcode
          }
        },
        :products => [
          {
            :id => "wine_#{wine.id}",
            :name => "Bottle of wine",
            :description => "Bottle of wine",
            :url => "http://127.0.0.1/admin/wines/#{wine.id}",
            :length => 20,
            :width => 15,
            :height => 10,
            :weight => 1,
            :quantity => 1,
            :price => price*100
          }
        ]
      }
    }
    require 'json'

    puts params.to_json

    headers = {
      'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(url, headers)
    # req.form_data = params
    req.body = params.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(req)
    }
    
    response = JSON.parse(connection.read_body)
    # puts connection
    connection.read_body
    # puts response

    # channel: “ecommerce”, “desktop”, “tablet”, “mobile”

    # {
    #   "quote_collection": { 
    #               "channel": "pos",
    #                  "page": "product",
    #            "session_id": "example123",
    #          "basket_value": 1999,
    #       "pickup_store_id": "448",
    #     "delivery_location": {                         
    #       "address": {                                               
    #         "postcode":      "EC2A 3LT"              
    #       }
    #     },
    #     "vehicle":           "parcel_car"
    #   }
    # }

  end

  def shutl_book(quote, order)

    token = shutl_token

    #**************************
    # Requests quote:

    domain = shutl_url
    url = URI("#{domain}/bookings")

    params = {
      :booking => {
        :quote_id => quote, 
        :merchant_booking_reference => "order_#{order.id}",
        :pickup_location => {
          :address => {
            :name         => order.warehouse.title,
            :line_1       => order.warehouse.address.line,
            :postcode     => order.warehouse.address.postcode,
            :city         => "London",
            :country      => "GB"
          },
          :contact => {
            :name =>  order.warehouse.title,
            :email => order.warehouse.email,
            :phone => order.warehouse.phone
          }
        },
        :delivery_location => {
          :address => {
            :name         => order.client.name,
            :line_1       => order.address.line,
            :postcode     => order.address.postcode,
            :city         => "London",
            :country      => "GB"
          },
          :contact => {
            :name =>  order.client.name,
            :email => order.client.email,
            :phone => order.client.mobile
          }
        }
      }
    }

    headers = {
      'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(url, headers)
    # req.form_data = params
    req.body = params.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(req)
    }
    
    response = JSON.parse(connection.read_body)
    # puts connection
    # connection.read_body
    puts response
    unless response.nil?
      return response['booking']['reference']
    else
      return nil
    end
# Booking:
# {
#   "booking": {
#     "quote_id": "1a2b3c-asap", 
#     "merchant_booking_reference": "YOUR_REF"
#   }
# }
# {"booking"=>{"reference"=>"V4A2MRR", "delivery_window_start"=>"2014-10-13T20:00+01:00", "delivery_window_finish"=>"2014-10-13T21:00+01:00"}}
  end

end
