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
    # puts PP.pp(request.request_parameters,'',80)

    # Solr:
    @search = Wine.search do
      fulltext params[:keywords]
    end
    puts PP.pp(@search.total,'',80)
    # puts PP.pp(@search.results,'',80)
    @results = @search.results

    respond_to do |format|
      format.json
    end
  end

end
