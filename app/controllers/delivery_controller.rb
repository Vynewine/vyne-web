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

      key = 'order:' + order.id.to_s + ':courier_location'

      DataCache.data.multi do
        DataCache.set(key, Time.now.strftime('%F %T'))
        DataCache.data.expire(key, 30)
      end

      result = {
          :errors => [],
          :data => {
              :name => '',
              :lat => 0,
              :lng => 0
          }
      }

      unless order.delivery_courier.blank?
        unless order.delivery_courier['lat'].blank? || order.delivery_courier['lng'].blank?
          result[:data][:lat] = order.delivery_courier['lat']
          result[:data][:lng] = order.delivery_courier['lng']
        end

        unless order.delivery_courier['name'].blank?
          result[:data][:name] = order.delivery_courier['name']
        end
      end

      render json: result

    end
  end
end