require 'json'
require 'sprockets/railtie'
require 'net/http'
require 'json'

class Admin::AdvisorsController < ApplicationController
  include ShutlHelper
  include UserMailer


  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  respond_to :html, :js

  def index
    @orders = Order.where(status_id: [1]).order(:id) # Ignores delivered and cancelled
    @categories = Category.all
  end

  def item
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
    @categories = Category.all
    @warehouses = Warehouse.where(:id => @order.information['warehouses'].map{ |warehouse| warehouse['id'] })
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

    @order_item.wine = wine
    @order_item.cost = inventory.cost
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

    #0 Save Delivery Quote
    quote = {
        :id => params[:quote],
        :price => params[:price],
        :vehicle => params[:vehicle],
        :pickup_start => params[:pickup_start],
        :pickup_finish => params[:pickup_finish],
        :delivery_start => params[:delivery_start],
        :delivery_finish => params[:delivery_finish],
        :valid_until => params[:valid_until]
    }

    order.delivery_quote = quote

    #1 Charge Card

    payment_data = order.payment
    stripe_token = payment_data.stripe
    value = (order.total_price * 100).to_i

    if order.status_id != 2
      charge_details = charge_card(value, stripe_token)
      if charge_details.paid
        order.status_id = 2 # paid
      end
    end

    #2 Schedule Shutl

    if order.status_id == 2
      if order.save

        booking_response = shutl_book(params[:quote], order)

        if booking_response.is_a?(Net::HTTPSuccess)

          booking_hash = JSON.parse(booking_response.read_body)
          booking_ref = nil

          unless booking_hash.blank?
            unless booking_hash['booking'].blank?
              unless booking_hash['booking']['reference'].blank?
                booking_ref = booking_hash['booking']['reference']
              end
            end
          end

          if booking_ref.nil?
            @message = "error:Couldn't do the booking."
            puts json: booking_response
          else
            order.delivery_token = booking_ref
            order.delivery_status = booking_hash
            order.status_id = 4 #pickup
            if order.save
              @message = 'Success'

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
          puts json: booking_response
          booking_error = JSON.parse(booking_response.read_body)
          puts booking_error
          @message = "error:Couldn't do the booking. " + booking_error['errors'].to_json
        end
      else
        @message = "error:Couldn't save order after booking"
      end
    else
      @message = "error:The payment was not processed. #{charge_details.description}"
      order.status_id = 3 #payment failed
      order.save
    end

    if @message == 'Success'
      order_receipt(order)
      merchant_order_confirmation(order)
    end

    respond_to do |format|
      if @message == 'Success'
        flash[:message] = @message
      else
        flash[:alert] = @message
      end

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
        with(:category_ids, params[:categories])
      end

      if params[:single]
        with(:single_estate, true)
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
                :region => wine.region.blank? ? '' : wine.region.name,
                :subregion => wine.subregion.nil? ? '' : wine.subregion.name,
                :locale => wine.locale.blank? ? '' : wine.locale.name,
                :id => wine.id,
                :appellation => wine.appellation.blank? ? '' : wine.appellation.name,
                :name => wine.name,
                :vintage => wine.txt_vintage,
                :single_estate => wine.single_estate,
                :type => wine.type.name,
                :compositions => wine.composition.composition_grapes.map { |c| { :name => c.grape.name, :percentage => c.percentage }},
                :note => wine.note,
                :warehouse => warehouse_id,
                :agendas => inv.warehouse.agendas,
                :cost => inv.cost.to_s,
                :price => inv.category.price,
                :quantity => inv.quantity,
                :category => inv.category.name + ' - £' + inv.category.price.to_s,
                :warehouse_distance => warehouse['distance'],
                :bottle_size => wine.bottle_size
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


  # Requests quotes:

  def shutl_quotes(order)

    token = shutl_token

    domain = Rails.application.config.shutl_url

    url = URI("#{domain}/quote_collections")

    basket_value = (order.total_cost * 100).to_i

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
        :vehicle => 'bicycle',
        #:products => products
      }
    }

    puts params.to_json

    headers = {
      'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(url, headers)
    # req.form_data = params
    req.body = params.to_json
    connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https' ) {|http|
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
    res = Net::HTTP::start(url.hostname, url.port, :use_ssl => url.scheme == 'https' ) {|http|
      http.request(req)
    }

    res
  end

end
