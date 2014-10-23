require 'json'
require 'sprockets/railtie'
require 'net/http'
require 'json'

class Admin::AdvisorsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  respond_to :html, :js

  def index
    @orders = Order.where(status_id: [1]) # Ignores delivered and cancelled
    @categories = Category.all
  end

  def item
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
    @categories = Category.all
  end

  def update
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
    wine = Wine.find(params['wine-id'])
    warehouse = Warehouse.find(params['warehouse-id'])
    inventory = Inventory.find_by(:warehouse => warehouse, :wine => wine)

    if !@order.warehouse.nil? && @order.warehouse.id.to_s != params['warehouse-id']
      flash[:error] = 'Warehouse doesn\'t match warehouse chosen for previous wine'
      redirect_to admin_order_path @order and return
    end

    puts json: @order_item.cost.to_s
    puts json: inventory.cost.to_s

    @order_item.wine = wine
    @order_item.cost = inventory.cost
    @order_item.price = @order_item.category.price
    @order.warehouse = warehouse
    @order.advisor = current_user
    @order_item.save
    @order.save
    respond_to do |format|
      format.html { redirect_to admin_order_path @order}
    end
  end

  def choose
    @order = Order.find(params[:order])
    quotes = shutl_quotes(@order)
    @quotes = JSON.parse(quotes) # Hash obj
  end

  def complete
    logger.warn 'Complete order request'

    order = Order.find(params[:order])

    #1 Charge Card

    payment_data = order.payment
    stripe_token = payment_data.stripe
    value = (order.total_price * 100).to_i
    charge_details = charge_card(value, stripe_token)
    if charge_details.paid
      order.status_id = 2 # paid
      if order.save

        #2 Schedule Shutl

        booking_response = shutl_book(params[:quote], order)
        booking_hash = JSON.parse(booking_response)
        booking_ref = nil

        unless booking_hash.nil?
          booking_ref = booking_hash['booking']['reference']
        end

        if booking_ref.nil?
          @message = "error:Couldn't do the booking."
        else
          order.delivery_token = booking_ref
          order.delivery_status = booking_response
          order.status_id = 4 #pickup
          if order.save
            @message = 'success'

            #3 Reduce Inventory Count

            order.order_items.each do |item|
              inventory = Inventory.find_by(:wine => item.wine, :warehouse => order.warehouse)
              inventory.quantity = inventory.quantity - 1
              inventory.save #TODO: Handle inventory update failure
            end

          else
            @message = "error:Couldn't save order after booking"
          end
        end
      else
        @message = "error:Couldn't save order after booking"
      end
    else
      @message = "error:The payment was not processed. #{charge_details.description}"
      order.status_id = 3 #payment failed
    end

    respond_to do |format|
      flash[:error] = @message
      format.html { redirect_to admin_order_path order}
    end

  end

  def results
    require 'pp'
    puts '--------------------------'
    logger.warn 'Search request'
    puts PP.pp(params[:keywords],'',80)
    puts PP.pp(request.request_parameters,'',80)

    order = Order.find(params[:order_id])

    warehouses = order.information['warehouses'].sort! { |a,b| a['distance'] <=> b['distance'] }

    # Solr search

    @search = Wine.search do
      fulltext params[:keywords]


      with(:warehouse_ids, params[:warehouses].split(","))

      unless params[:categories].nil?
        with(:price_categories, params[:categories])
      end

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

    #Transform Results to order by warehouse that's closest to the client

    wines = []

    warehouses.each{ |warehouse|

      warehouse_id =  warehouse['id']

      @search.results.each{|wine|
        wine.inventories.each{ |inv|

          if inv.warehouse.id.to_s == warehouse_id.to_s
            wines << {
                :countryCode => wine.producer.country.alpha_2,
                :countryName => wine.producer.country.name,
                :subregion => wine.subregion.nil? ? '' : wine.subregion.name,
                :id => wine.id,
                :appellation => wine.appellation.name,
                :name => wine.name,
                :vintage => wine.vintage,
                :single_estate => wine.single_estate,
                :vegan => wine.vegan,
                :organic => wine.organic,
                :types => wine.types.map {|t| t.name},
                :compositions => wine.compositions.map { |c| { :name => c.grape.name, :quantity => c.quantity }},
                :notes => wine.notes.map {|n| n.name},
                :warehouse => warehouse_id,
                :agendas => inv.warehouse.agendas,
                :cost => inv.cost.to_s,
                :price => inv.category.price,
                :quantity => inv.quantity,
                :category => inv.category.name + ' - £' + inv.category.price.to_s,
                :warehouse_distance => warehouse['distance']
            }
          end
        }
      }
    }

    @results = wines


    respond_to do |format|
      format.json
    end
  end

  private

  #TODO: Capture Response Here!!!!
  def charge_card(value, stripe_token)
    puts 'Charging card'
    Stripe.api_key = Rails.application.config.stripe_key
    Stripe::Charge.create(
      :amount   => value, 
      :currency => 'gbp',
      :customer => stripe_token
    )
  end

  # Requests token:

  def shutl_token
    puts 'Requesting delivery token'

    domain = Rails.application.config.shutl_url
    shutl_id = Rails.application.config.shutl_id
    shutl_secret = Rails.application.config.shutl_secret

    url = URI("#{domain}/token")

    params = {
      :client_id => shutl_id,
      :client_secret => shutl_secret,
      :grant_type => 'client_credentials'
    }

    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded'
    }

    req_token = Net::HTTP::Post.new(url, headers)
    req_token.form_data = params
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
      http.request(req_token)
    }

    response = JSON.parse(connection.read_body)
    response['access_token']
  end

  # Requests quotes:

  def shutl_quotes(order)

    token = shutl_token

    domain = Rails.application.config.shutl_url

    url = URI("#{domain}/quote_collections")

    basket_value = ((order.order_items.map { |item| item.cost}).inject(:+)*100).to_i

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
        :page => 'product',
        :session_id => 'example123',
        :basket_value => basket_value,
        :pickup_location => {
          :address => {
            :postcode => order.warehouse.address.postcode
          }
        },
        :delivery_location => {
          :address => {
            :postcode => order.address.postcode
          }
        },
        :products => products
      }
    }

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

    connection.read_body

  end

  def shutl_book(quote, order)

    token = shutl_token

    #**************************
    # Requests quote:

    domain = Rails.application.config.shutl_url
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

    connection.read_body

  end

end
