class Admin::AdvisorsController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  respond_to :html, :js

  def index
    @orders = Order.where.not(status_id: [1,7,8]) # Ignores the new, delivered and cancelled
    @categories = Category.all
  end

  def choose

    # shutlId = "UOuPfVIAvP4BJWDmXdCiSw=="
    # shutlSecret = "DAiXY/UzTM14g6PAqAHDrm/ILwkJ3fT5mnh7aT15JiPI6YLz5GYN7qLtx4Yac60PFN+rZRuZuFyi0FExri3F6w=="
    # shutlUrl = "https://sandbox-v2.shutl.co.uk"

    require 'pp'
    puts '--------------------------'
    logger.warn "Choice request"
    puts PP.pp(params,'',80)
    order = Order.find(params[:order])
    warehouse = Warehouse.find(params[:warehouse])
    wine = Wine.find(params[:wine])
    inventory = Inventory.find_by(:wine_id => params[:wine], :warehouse_id => params[:warehouse])
    order.wine = wine
    order.quantity = 1
    order.status_id = 4 # paying
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
          order.status_id = 5 # paid
          if order.save
            # Shutl
            deliverySent = request_delivery
            if deliverySent == true
              @message = 'success'
            end
          end
        else
          @message = "error:The payment was not processed. #{chargeDetails.description}"
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

  def request_delivery
    puts "Requesting delivery"
    require 'net/http'
    require 'json'
    # shutlId = "UOuPfVIAvP4BJWDmXdCiSw=="
    # shutlSecret = "DAiXY/UzTM14g6PAqAHDrm/ILwkJ3fT5mnh7aT15JiPI6YLz5GYN7qLtx4Yac60PFN+rZRuZuFyi0FExri3F6w=="
    #**************************
    domain = "https://sandbox-v2.shutl.co.uk"
    #**************************
    shutlId = "HnnFB2UbMlBXdD9h4UzKVQ=="
    shutlSecret = "pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A=="
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
    token = response['access_token']
    puts response
    # puts token

    #**************************
    # Requests quote:

    url = URI("#{domain}/quote_collections")

    params = {
      :quote_collection => {
        :channel => "pos",
        :page => "product",
        :session_id => "example123",
        :basket_value => 1999,
        :pickup_store_id => "southwark",
        :delivery_location => {
          :address => {
            :postcode => "EC2A 3LT"
          }
        },
        :products => [
          {
            :id => "item1",
            :name => "Item One",
            :description => "Large Box",
            :url => "http://shop.com/item1",
            :length => 20,
            :width => 15,
            :height => 10,
            :weight => 1,
            :quantity => 1,
            :price => 1500
          }
        ]
      }
    }
    # require 'json'

    # puts params.to_json

    headers = {
      # 'Content-Type' => 'application/x-www-form-urlencoded',
      'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(url, headers)
    # req.form_data = params
    req.body = params.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(req)
    }
    
    response = JSON.parse(connection.read_body)
    puts connection
    puts connection.read_body
    puts response



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





# Booking:
# {
#   "booking": {
#     "quote_id": "1a2b3c-asap", 
#     "merchant_booking_reference": "YOUR_REF"
#   }
# }


# resp, data = http.post(path, data, headers)
# puts PP.pp(resp,'',80)

# params = {
#   :client_id => shutlId,
#   :client_secret => shutlSecret,
#   :grant_type => 'client_credentials'
# }
# resp = Net::HTTP.post_form(url, headers)
# resp_text = resp.body
# puts PP.pp(resp_text,'',80)
  end

end
