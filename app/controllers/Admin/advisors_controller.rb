require 'json'
require 'sprockets/railtie'
require 'net/http'
require 'json'

class Admin::AdvisorsController < ApplicationController
  include ShutlHelper
  include UserMailer
  include CoordinateHelper

  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  respond_to :html, :js

  def item
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order
    @categories = Category.all.order(:id)
  end

  def update
    @order_item = OrderItem.find(params[:id])
    @order = @order_item.order

    unless @order_item.wine.blank?
      advised_wine = @order_item.wine
      inventory = Inventory.find_by(:warehouse => @order.warehouse, :wine => advised_wine)
      inventory.quantity += 1
      unless inventory.save
        redirect_to admin_order_path @order, :flash => {:error => inventory.errors.full_messages().join(', ')}
        return
      end
    end

    wine = Wine.find(params['wine_id'])

    inventory = Inventory.find_by(:warehouse => @order.warehouse, :wine => wine)

    if inventory.quantity == 0
      flash[:error] = "Insufficient stock quantity for #{inventory.vendor_sku}"
      redirect_to admin_order_path @order
      return
    end

    inventory.quantity -= 1

    unless inventory.save
      flash[:error] = inventory.errors.full_messages().join(', ')
      redirect_to admin_order_path @order
      return
    end

    @order_item.wine = wine
    @order_item.cost = inventory.cost
    @order_item.price = inventory.cost
    @order_item.inventory = inventory
    @order_item.advisory_note = params['advisory_note']

    if @order_item.substitution_status == 'requested'
      @order_item.substitution_status = 'completed'
    end

    unless @order_item.save
      flash[:error] = @order_item.errors.full_messages().join(', ')
      redirect_to admin_order_path @order
      return
    end

    @order.advisor = current_user

    if @order.save
      redirect_to admin_order_path @order
    else
      flash[:error] = @order.errors.full_messages().join(', ')
      redirect_to admin_order_path @order
    end

  end

  def choose
    @order = Order.find(params[:order])
    quotes = shutl_quotes(@order)
    @quotes = JSON.parse(quotes)
  end

  def complete

    order = Order.find(params[:order])

    if order.delivery_provider == 'google_coordinate' && !order.delivery_token.blank?
      CoordinateHelper.cancel_job(order)
    end

    # Save Delivery Quote
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

    # Schedule Shutl
    if order.save

      booking_response = shutl_book(params[:quote], order)

      if booking_response[:errors].blank?

        booking_hash = booking_response[:data]
        booking_ref = nil

        unless booking_hash.blank?
          unless booking_hash['booking'].blank?
            unless booking_hash['booking']['reference'].blank?
              booking_ref = booking_hash['booking']['reference']
            end
          end
        end

        if booking_ref.nil?
          @message = 'Booking Reference is missing'
        else
          order.delivery_token = booking_ref
          order.delivery_status = booking_hash
          order.delivery_provider = 'shutl'
          if order.save
            @message = 'Success'
          else
            @message = "Couldn't save order after booking"
          end
        end
      else
        @message = booking_response[:errors]
      end
    else
      @message = order.errors
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

    @search = Inventory.search do
      fulltext params[:keywords]

      with(:warehouse_id, order.warehouse_id)

      unless params[:categories].nil?
        with(:category_id, params[:categories])
      end

      if params[:single]
        with(:single_estate, true)
      end

      unless params[:price_range_min].blank? || params[:price_range_max].blank?
        with(:cost).between(params[:price_range_min].to_f..params[:price_range_max].to_f)
      end

    end

    wines = []

    @search.results.each do |inventory|

      #inventory = wine.inventories.select { |inv| inv.warehouse == order.warehouse }.first

      unless inventory.quantity == 0
        wines << {
            :countryCode => inventory.wine.producer.country.alpha_2,
            :countryName => inventory.wine.producer.country.name,
            :region => inventory.wine.region.blank? ? '' : inventory.wine.region.name,
            :subregion => inventory.wine.subregion.nil? ? '' : inventory.wine.subregion.name,
            :locale => inventory.wine.locale.blank? ? '' : inventory.wine.locale.name,
            :id => inventory.wine.id,
            :appellation => inventory.wine.appellation.blank? ? '' : inventory.wine.appellation.name,
            :name => inventory.wine.name,
            :vintage => inventory.wine.txt_vintage,
            :single_estate => inventory.wine.single_estate,
            :type => inventory.wine.type.name,
            :compositions => inventory.wine.composition.blank? ? '' : inventory.wine.composition.composition_grapes.map { |c| {:name => c.grape.name, :percentage => c.percentage} },
            :note => inventory.wine.note,
            :cost => inventory.cost.to_s,
            :price => inventory.category.blank? ? '' : inventory.category.price,
            :quantity => inventory.quantity,
            :category => inventory.category.blank? ? '' : inventory.category.name + ' - £' + inventory.category.price.to_s,
            :bottle_size => inventory.wine.bottle_size,
            :vendor_sku => inventory.vendor_sku,
            :producer => inventory.wine.producer.name,
            :inventory_id => inventory.id
        }

      end
    end

    @results = wines

    respond_to do |format|
      format.json
    end
  end

  def results_old

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

      inventory = wine.inventories.select { |inv| inv.warehouse == order.warehouse }.first

      unless inventory.blank? || inventory.quantity == 0 || inventory.category.blank?
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
            :bottle_size => wine.bottle_size,
            :vendor_sku => inventory.vendor_sku,
            :producer => wine.producer.name,
            :inventory_id => inventory.id
        }

      end
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
