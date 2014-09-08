class HomeController < ApplicationController
  def index
  end
  def warehouses
    @warehouses = Warehouse.all
  end
  def welcome
  end
end
