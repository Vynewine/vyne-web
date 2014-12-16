class DeliveryController < ApplicationController
  include CoordinateHelper

  before_action :authenticate_user!, :except => [:index]
  authorize_actions_for UserAuthorizer, :except => [:index]
  authority_actions :get_courier_location => 'read'

  def index
    delivery_areas = Warehouse.delivery_area_by_city

    @areas = ''

    unless delivery_areas.blank?
      if delivery_areas.is_a?(RGeo::Cartesian::MultiPolygonImpl)
        delivery_areas.each_with_index do |polygon, polygon_index|
          polygon.exterior_ring.points.each_with_index do |point, index|
            if index == 0
              @areas += '['
            end
            @areas += '[' + point.y.to_s + ', ' + point.x.to_s + ']'
            if index < (polygon.exterior_ring.points.length - 1)
              @areas += ','
            else
              @areas += ']'
            end
          end
          if polygon_index < (delivery_areas.count - 1)
            @areas += ','
          end
        end
      elsif delivery_areas.is_a?(RGeo::Cartesian::PolygonImpl)
        delivery_areas.exterior_ring.points.each_with_index do |point, index|
          if index == 0
            @areas += '['
          end
          @areas += '[' + point.y.to_s + ', ' + point.x.to_s + ']'
          if index < (delivery_areas.exterior_ring.points.count - 1)
            @areas += ','
          else
            @areas += ']'
          end
        end
      end
    end
  end

  def get_courier_location
    order = Order.find_by(id: params[:id], client_id: current_user)
    if order.blank?
      render json: ['404'], status: :not_found
      return
    else
      courier_info = get_latest_courier_position(order)
      unless courier_info[:data].blank?
        order.delivery_courier = courier_info[:data]

        order.save
      end

      render json: courier_info

    end
  end
end