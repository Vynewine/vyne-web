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
    @warehouses = Warehouse.where(:id => @order.information['warehouses'].map { |warehouse| warehouse['id'] })
  end

  def update
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
    wine = Wine.find(params['wine-id'])

    inventory = Inventory.find_by(:warehouse => @order.warehouse, :wine => wine)

    @order_item.wine = wine
    @order_item.cost = inventory.cost

    @order.advisor = current_user
    @order_item.save
    @order.save
    respond_to do |format|
      format.html { redirect_to admin_order_path @order }
    end
  end

  def choose
    @order = Order.find(params[:order])
    quotes = shutl_quotes(@order)
    @quotes = JSON.parse(quotes)
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
        :valid_until => params[:valid_until],
        :delivery_promise => params[:delivery_promise]
    }

    order.delivery_quote = quote

    #1 Charge Card

    payment_data = order.payment
    stripe_card_id = payment_data.stripe_card_id
    stripe_customer_id = payment_data.user.stripe_id
    value = (order.total_price * 100).to_i

    if order.status_id != 2
      charge_details = charge_card(value, stripe_card_id, stripe_customer_id)

      if charge_details.paid
        order.status_id = 2 # paid
      end

      unless charge_details.id.blank?
        order.charge_id = charge_details.id
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
        flash[:notice] = @message
      else
        flash[:alert] = @message
      end

      format.html { redirect_to admin_order_path order }
    end

  end

  def results

    order = Order.find(params[:order_id])

    # Solr search

    @search = Wine.search do
      fulltext params[:keywords]

      with(:warehouse_ids, order.warehouse_id)

      unless params[:categories].nil?
        with(:category_ids, params[:categories])
      end

      if params[:single]
        with(:single_estate, true)
      end

    end

    wines = []

    @search.results.each do |wine|

      inventory = wine.inventories.select{ |inv| inv.warehouse == order.warehouse }.first

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
          :compositions => wine.composition.blank? ? '' : wine.composition.composition_grapes.map { |c| {:name => c.grape.name, :percentage => c.percentage} },
          :note => wine.note,
          :cost => inventory.cost.to_s,
          :price => inventory.category.price,
          :quantity => inventory.quantity,
          :category => inventory.category.name + ' - £' + inventory.category.price.to_s,
          :bottle_size => wine.bottle_size
      }
    end

    @results = wines

    respond_to do |format|
      format.json
    end
  end

  private

  #TODO: Capture Response Here!!!!
  def charge_card(value, stripe_card_id, stripe_customer_id)
    puts 'Charging card'
    Stripe.api_key = Rails.application.config.stripe_key
    Stripe::Charge.create(
        :amount => value,
        :currency => 'gbp',
        :customer => stripe_customer_id,
        :card => stripe_card_id
    )
  end

end
