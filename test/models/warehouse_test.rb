require 'test_helper'
require 'rgeo-geojson'
require 'json'

class WarehouseTest < ActiveSupport::TestCase
  test 'Can save delivery area' do

    warehouse = Warehouse.create!({
                                      :title => 'New Warehouse',
                                      :email => 'vyne@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one),
                                      :delivery_area => 'POLYGON((0 0,4 0,4 4,0 4,0 0))'
                                  })

    new_warehouse = Warehouse.find(warehouse.id)

    assert_equal(5, new_warehouse.delivery_area.exterior_ring.points.count)

  end

  test 'Can add points to delivery area' do

    factory = ::RGeo::Cartesian.preferred_factory

    p1 = factory.point(-0.125141, 51.510612)
    p2 = factory.point(-0.122995, 51.517342)
    p3 = factory.point(-0.127974, 51.521348)

    ring = factory.linear_ring([p1, p2, p3, p1])

    warehouse = Warehouse.create!({
                                      :title => 'New Warehouse',
                                      :email => 'vyne@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one),
                                      :delivery_area => factory.polygon(ring)
                                  })

    new_warehouse = Warehouse.find(warehouse.id)

    assert_equal(4, new_warehouse.delivery_area.exterior_ring.points.count)

    assert_equal(JSON.parse('{"type":"Polygon", "coordinates":[[[-0.125141, 51.510612], [-0.122995, 51.517342], [-0.127974, 51.521348], [-0.125141, 51.510612]]]}'),
                 RGeo::GeoJSON.encode(new_warehouse.delivery_area))

  end

  test 'Can create area from JSON' do
    coordinates = '[[[-0.125141, 51.510612], [-0.122995, 51.517342], [-0.127974, 51.521348], [-0.125141, 51.510612]]]'

    area = {
        :type => 'Polygon',
        :coordinates => JSON.parse(coordinates)
    }

    polygon = RGeo::GeoJSON.decode(area.to_json, :json_parser => :json)

    assert_equal(4, polygon.exterior_ring.points.count)

  end

  test 'Can save coordinates' do

    coordinates = '[[[-0.125141, 51.510612], [-0.122995, 51.517342], [-0.127974, 51.521348], [-0.125141, 51.510612]]]'

    warehouse = Warehouse.create!({
                                      :title => 'New Warehouse',
                                      :email => 'vyne@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one),
                                      :area => coordinates
                                  })

    new_warehouse = Warehouse.find(warehouse.id)

    assert_equal(4, new_warehouse.delivery_area.exterior_ring.points.count)

  end

  test 'Can save empty area' do
    coordinates = nil

    warehouse = Warehouse.create!({
                                      :title => 'New Warehouse',
                                      :email => 'vyne@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one),
                                      :area => coordinates
                                  })

    new_warehouse = Warehouse.find(warehouse.id)

    assert_equal(0, new_warehouse.delivery_area.exterior_ring.points.count)
  end

  test 'Can loop trough points' do

    coordinates = '[[[-0.125141, 51.510612], [-0.122995, 51.517342], [-0.127974, 51.521348], [-0.125141, 51.510612]]]'

    warehouse = Warehouse.create!({
                                      :title => 'New Warehouse',
                                      :email => 'vyne@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one),
                                      :area => coordinates
                                  })

    new_warehouse = Warehouse.find(warehouse.id)


    new_warehouse.delivery_area.exterior_ring.points.each do |point|
      puts point.x
      puts point.y
    end
  end

  test 'Can convert delivery area to json' do
    coordinates = '[[[-0.125141, 51.510612], [-0.122995, 51.517342], [-0.127974, 51.521348], [-0.125141, 51.510612]]]'

    warehouse = Warehouse.create!({
                                      :title => 'New Warehouse',
                                      :email => 'vyne@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one),
                                      :area => coordinates
                                  })

    new_warehouse = Warehouse.find(warehouse.id)

    puts new_warehouse.area

  end

  test 'Will merge multiple overlapping delivery areas' do

    Warehouse.create!({
                          :title => 'New Warehouse 1',
                          :email => 'vyne@vyne.london',
                          :phone => '07718225201',
                          :address => addresses(:one),
                          :delivery_area => 'POLYGON((-0.080853 51.52263,-0.073814 51.5206,-0.069866 51.517396,-0.069523 51.511841,-0.069523 51.50714,-0.072956 51.50308,-0.085144 51.501797,-0.094242 51.501263,-0.103855 51.505751,-0.107288 51.5112,-0.1054 51.51793,-0.100422 51.522737,-0.093899 51.523484,-0.086346 51.523271,-0.081539 51.522843,-0.080853 51.52263))',
                          :active => true

                      })
    Warehouse.create!({
                          :title => 'New Warehouse 2',
                          :email => 'vyne@vyne.london',
                          :phone => '07718225201',
                          :address => addresses(:one),
                          :delivery_area => 'POLYGON((-0.107288 51.534591,-0.097504 51.534164,-0.089951 51.532669,-0.086517 51.528611,-0.082912 51.52295,-0.083771 51.516007,-0.086517 51.509063,-0.096474 51.504255,-0.108662 51.502759,-0.116901 51.503614,-0.12291 51.50746,-0.129604 51.511841,-0.132523 51.516648,-0.134926 51.52295,-0.132866 51.528717,-0.124798 51.533416,-0.114498 51.535658,-0.107288 51.534591))',
                          :active => true
                      })

    delivery_areas = Warehouse.delivery_area_by_city

    unless delivery_areas.blank?
      if delivery_areas.is_a?(RGeo::Cartesian::MultiPolygonImpl)
        delivery_areas.each do |polygon|
          puts 'sweet new polygon'
          polygon.exterior_ring.points.each do |point|
            puts point.x.to_s + ', ' + point.y.to_s
          end
        end
      elsif delivery_areas.is_a?(RGeo::Cartesian::PolygonImpl)
        delivery_areas.exterior_ring.points.each do |point|
          puts point.x.to_s + ', ' + point.y.to_s
        end
      end
    end
  end

  test 'Will merge multiple overlapping and separate delivery areas' do

    Warehouse.create!({
                          :title => 'New Warehouse 1',
                          :email => 'vyne@vyne.london',
                          :phone => '07718225201',
                          :address => addresses(:one),
                          :delivery_area => 'POLYGON((-0.080853 51.52263,-0.073814 51.5206,-0.069866 51.517396,-0.069523 51.511841,-0.069523 51.50714,-0.072956 51.50308,-0.085144 51.501797,-0.094242 51.501263,-0.103855 51.505751,-0.107288 51.5112,-0.1054 51.51793,-0.100422 51.522737,-0.093899 51.523484,-0.086346 51.523271,-0.081539 51.522843,-0.080853 51.52263))',
                          :active => true

                      })
    Warehouse.create!({
                          :title => 'New Warehouse 2',
                          :email => 'vyne@vyne.london',
                          :phone => '07718225201',
                          :address => addresses(:one),
                          :delivery_area => 'POLYGON((-0.107288 51.534591,-0.097504 51.534164,-0.089951 51.532669,-0.086517 51.528611,-0.082912 51.52295,-0.083771 51.516007,-0.086517 51.509063,-0.096474 51.504255,-0.108662 51.502759,-0.116901 51.503614,-0.12291 51.50746,-0.129604 51.511841,-0.132523 51.516648,-0.134926 51.52295,-0.132866 51.528717,-0.124798 51.533416,-0.114498 51.535658,-0.107288 51.534591))',
                          :active => true
                      })
    #Area outside of merged polygon
    Warehouse.create!({
                          :title => 'New Warehouse 3',
                          :email => 'vyne@vyne.london',
                          :phone => '07718225201',
                          :address => addresses(:one),
                          :delivery_area => 'POLYGON((-0.164108 51.499126,-0.165825 51.49421,-0.181274 51.496775,-0.164108 51.499126))',
                          :active => true
                      })

    delivery_areas = Warehouse.delivery_area_by_city

    unless delivery_areas.blank?
      if delivery_areas.is_a?(RGeo::Cartesian::MultiPolygonImpl)
        delivery_areas.each do |polygon|
          polygon.exterior_ring.points.each do |point|
            puts point.x.to_s + ', ' + point.y.to_s
          end
        end
      elsif delivery_areas.is_a?(RGeo::Cartesian::PolygonImpl)
        delivery_areas.exterior_ring.points.each do |point|
          puts point.x.to_s + ', ' + point.y.to_s
        end
      end
    end
  end

  test 'Create polygon around warehouse' do

    points = circle_path({:lng => -0.108105959289054, :lat => 51.5200685165148}, 4023, 30, true)
    points.each do |point|
      puts '[' + point[1].to_s + ', ' + point[0].to_s + '],'
    end
  end

  # Handy radius to polygon function from
  # https://gist.github.com/straydogstudio/4992733
  def circle_path(center, radius, segments, complete_path = false)
    # For increased accuracy, if your data is in a localized area, add the elevation in meters to r_e below:
    r_e = 6378137.0
    d2r ||= Math::PI/180
    multipliers ||= begin
      d_Rad = 2*Math::PI/segments
      (segments + (complete_path ? 1 : 0)).times.map do |i|
        rads = d_Rad*i
        y = Math.sin(rads)
        x = Math.cos(rads)
        [y.abs < 0.01 ? 0.0 : y, x.abs < 0.01 ? 0.0 : x]
      end
    end
    center_lat = center[:lat]
    center_lng = center[:lng]
    d_Lat = radius/(r_e*d2r)
    d_Lng = radius/(r_e*Math.cos(d2r*center_lat)*d2r)
    multipliers.map {|m| [center_lat + m[0]*d_Lat, center_lng + m[1]*d_Lng]}
  end
end