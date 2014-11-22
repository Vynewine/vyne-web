class DeliveryController < ApplicationController
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
end