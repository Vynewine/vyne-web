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

    p1 = factory.point(-0.125141,51.510612)
    p2 = factory.point(-0.122995,51.517342)
    p3 = factory.point(-0.127974,51.521348)

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

end