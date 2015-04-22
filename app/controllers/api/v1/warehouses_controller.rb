class API::V1::WarehousesController < ApplicationController
  def index
    render json: {test: 'test'}
  end
end