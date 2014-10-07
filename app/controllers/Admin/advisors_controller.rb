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
        # @message = 'success'

        paymentData = order.payment

        stripeToken = paymentData.stripe # cus_4uQiP8ZhPAKXoa
        # Later...
        # customer_id = get_stripe_customer_id(stripeToken)

        chargeDetails = Stripe::Charge.create(
          :amount   => 1500, # $15.00 this time
          :currency => "gbp",
          :customer => stripeToken
        )
        # puts '--------------------------'
        # puts '=========================='
        # puts PP.pp(chargeDetails,'',80)
        # puts '=========================='
        # puts '--------------------------'
        if chargeDetails.paid == true
          order.status_id = 5 # paid
          if order.save
            # shutl request
            # mail request
            @message = 'success'
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
      if params[:vegetarian]
        with(:vegetarian, true)
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

end
