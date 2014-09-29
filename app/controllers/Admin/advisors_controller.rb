class Admin::AdvisorsController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  respond_to :html, :js

  def index
    @orders = Order.where.not(status_id: [1,7,8]) # Ignores the new, delivered and cancelled
  end

  def results
    require 'pp'
    puts '--------------------------'
    logger.warn "Search request"
    puts PP.pp(params[:keywords],'',80)
    puts PP.pp(request.request_parameters,'',80)

    # Solr:
    @search = Wine.search do
      fulltext params[:keywords]

      # facet(:warehouse_id) do
      with(:warehouse_ids, params[:warehouse])
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
    
    puts '--------------------------'
    puts ' RESULTS'
    puts '--------------------------'
    @results.each do |wine|
      puts '- - - - - - - - - - - - -'
      puts PP.pp(wine.name,'',80)
      # puts PP.pp(wine.appellation,'',80)
      # puts PP.pp(wine.vintage,'',80)
      # puts PP.pp(wine.producer.country.alpha_2,'',80)
      # puts PP.pp(wine.producer.country.name,'',80)
      # puts PP.pp(wine.compositions,'',80)
      # puts PP.pp(wine.grapes,'',80)
      # puts PP.pp(wine.warehouses,'',80)
      puts PP.pp(wine.subregion || 'none' ,'',80)
      puts '- - - - - - - - - - - - -'
    end
    puts '--------------------------'

    respond_to do |format|
      format.json
    end
  end

end
