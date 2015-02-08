require 'test_helper'
require 'rgeo-geojson'
require 'json'
require 'mocha/test_unit'

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

  test 'Can get delivery area without blowing up' do
    Warehouse.delivery_area_by_city
  end

  test 'Create polygon around warehouse' do
    points = circle_path({:lng => -0.108105959289054, :lat => 51.5200685165148}, 4023, 30, true)
    points.each do |point|
      puts '[' + point[1].to_s + ', ' + point[0].to_s + '],'
    end
  end

  test 'Will find warehouse for client within delivery area' do

    address_01 = Address.create!({
                                     :line_1 => '41a Farringdon St',
                                     :postcode => 'EC4A 4AN',
                                     :coordinates => 'POINT(-0.105019 51.517125)'
                                 })
    warehouse_01 = Warehouse.create!({
                                         :title => 'New Warehouse 1',
                                         :email => 'vyne@vyne.london',
                                         :phone => '07718225201',
                                         :address => address_01,
                                         :delivery_area => 'POLYGON((-0.105019 51.55330470820611, -0.04687851649324394 51.517110630598836, -0.10501899999999999 51.48094529179389, -0.16315948350675605 51.517110630598836))',
                                         :active => true
                                     })

    set_open_agenda(warehouse_01)


    found_warehouse = Warehouse.closest_to(51.517125, -0.105019)

    assert_equal(warehouse_01, found_warehouse.first)

  end

  test 'Will not find warehouse for client outside of the delivery area' do
    address_01 = Address.create!({
                                     :line_1 => '41a Farringdon St',
                                     :postcode => 'EC4A 4AN',
                                     :coordinates => 'POINT(-0.105019 51.517125)'
                                 })
    warehouse_01 = Warehouse.create!({
                                         :title => 'New Warehouse 1',
                                         :email => 'vyne@vyne.london',
                                         :phone => '07718225201',
                                         :address => address_01,
                                         :delivery_area => 'POLYGON((-0.105019 51.55330470820611, -0.04687851649324394 51.517110630598836, -0.10501899999999999 51.48094529179389, -0.16315948350675605 51.517110630598836))',
                                         :active => true
                                     })

    set_open_agenda(warehouse_01)


    found_warehouse = Warehouse.closest_to(51.519559, -0.164076)

    assert_equal(0, found_warehouse.count)
  end

  test 'Will find closest warehouse if client within area of two warehouses' do
    far_address = Address.create!({
                                      :line_1 => '41a Farringdon St',
                                      :postcode => 'EC4A 4AN',
                                      :coordinates => 'POINT(-0.105019 51.517125)'
                                  })
    far_warehouse = Warehouse.create!({
                                          :title => 'New Warehouse 1',
                                          :email => 'vyne@vyne.london',
                                          :phone => '07718225201',
                                          :address => far_address,
                                          :delivery_area => 'POLYGON((-0.105019 51.55330470820611, -0.04687851649324394 51.517110630598836, -0.10501899999999999 51.48094529179389, -0.16315948350675605 51.517110630598836))',
                                          :active => true
                                      })

    set_open_agenda(far_warehouse)

    close_address = Address.create!({
                                        :line_1 => '41a Farringdon St',
                                        :postcode => 'EC4A 4AN',
                                        :coordinates => 'POINT(-0.15343 51.535287)'

                                    })
    close_warehouse = Warehouse.create!({
                                            :title => 'New Warehouse 1',
                                            :email => 'vyne@vyne.london',
                                            :phone => '07718225201',
                                            :address => close_address,
                                            :delivery_area => 'POLYGON((-0.15343 51.57146670820611, -0.09526632073465373 51.53527262124437, -0.15343 51.499107291793884, -0.21159367926534628 51.53527262124437))',
                                            :active => true
                                        })

    set_open_agenda(close_warehouse)


    found_warehouse = Warehouse.closest_to(51.532108, -0.134439)
    found_far_warehouse = Warehouse.closest_to(51.523589, -0.116303)

    assert_equal(close_warehouse, found_warehouse.first)
    assert_equal(far_warehouse, found_far_warehouse.first)

  end

  test 'Will not find inactive warehouse for client within delivery area' do

    address_01 = Address.create!({
                                     :line_1 => '41a Farringdon St',
                                     :postcode => 'EC4A 4AN',
                                     :coordinates => 'POINT(-0.105019 51.517125)'
                                 })
    warehouse_01 = Warehouse.create!({
                                         :title => 'New Warehouse 1',
                                         :email => 'vyne@vyne.london',
                                         :phone => '07718225201',
                                         :address => address_01,
                                         :delivery_area => 'POLYGON((-0.105019 51.55330470820611, -0.04687851649324394 51.517110630598836, -0.10501899999999999 51.48094529179389, -0.16315948350675605 51.517110630598836))',
                                         :active => false
                                     })

    set_open_agenda(warehouse_01)


    found_warehouse = Warehouse.closest_to(51.517125, -0.105019)

    assert(0, found_warehouse.count)

  end

  test 'Will find farther warehouse if closer one is inactive' do
    far_address = Address.create!({
                                      :line_1 => '41a Farringdon St',
                                      :postcode => 'EC4A 4AN',
                                      :coordinates => 'POINT(-0.105019 51.517125)'
                                  })
    far_warehouse = Warehouse.create!({
                                          :title => 'New Warehouse 1',
                                          :email => 'vyne@vyne.london',
                                          :phone => '07718225201',
                                          :address => far_address,
                                          :delivery_area => 'POLYGON((-0.105019 51.55330470820611, -0.04687851649324394 51.517110630598836, -0.10501899999999999 51.48094529179389, -0.16315948350675605 51.517110630598836))',
                                          :active => true
                                      })

    set_open_agenda(far_warehouse)

    close_address = Address.create!({
                                        :line_1 => '41a Farringdon St',
                                        :postcode => 'EC4A 4AN',
                                        :coordinates => 'POINT(-0.15343 51.535287)'

                                    })
    close_warehouse = Warehouse.create!({
                                            :title => 'New Warehouse 2',
                                            :email => 'vyne@vyne.london',
                                            :phone => '07718225201',
                                            :address => close_address,
                                            :delivery_area => 'POLYGON((-0.15343 51.57146670820611, -0.09526632073465373 51.53527262124437, -0.15343 51.499107291793884, -0.21159367926534628 51.53527262124437))',
                                            :active => false
                                        })

    set_open_agenda(close_warehouse)

    found_warehouse = Warehouse.closest_to(51.532108, -0.134439)
    found_far_warehouse = Warehouse.closest_to(51.523589, -0.116303)

    assert_equal(1, found_warehouse.count)
    assert_equal(1, found_far_warehouse.count)
    assert_equal(far_warehouse, found_warehouse.first)
    assert_equal(far_warehouse, found_far_warehouse.first)

  end

  test 'Will find farther warehouse if closer one is closed' do
    far_address = Address.create!({
                                      :line_1 => '41a Farringdon St',
                                      :postcode => 'EC4A 4AN',
                                      :coordinates => 'POINT(-0.105019 51.517125)'
                                  })
    far_warehouse = Warehouse.create!({
                                          :title => 'New Warehouse 1',
                                          :email => 'vyne@vyne.london',
                                          :phone => '07718225201',
                                          :address => far_address,
                                          :delivery_area => 'POLYGON((-0.105019 51.55330470820611, -0.04687851649324394 51.517110630598836, -0.10501899999999999 51.48094529179389, -0.16315948350675605 51.517110630598836))',
                                          :active => true
                                      })

    set_open_agenda(far_warehouse)


    close_address = Address.create!({
                                        :line_1 => '41a Farringdon St',
                                        :postcode => 'EC4A 4AN',
                                        :coordinates => 'POINT(-0.15343 51.535287)'

                                    })
    close_warehouse = Warehouse.create!({
                                            :title => 'New Warehouse 2',
                                            :email => 'vyne@vyne.london',
                                            :phone => '07718225201',
                                            :address => close_address,
                                            :delivery_area => 'POLYGON((-0.15343 51.57146670820611, -0.09526632073465373 51.53527262124437, -0.15343 51.499107291793884, -0.21159367926534628 51.53527262124437))',
                                            :active => true
                                        })

    set_closed_agenda(close_warehouse)

    found_warehouse = Warehouse.closest_to(51.532108, -0.134439)
    found_far_warehouse = Warehouse.closest_to(51.523589, -0.116303)

    assert_equal(false, found_warehouse.first.is_open)
    assert_equal(far_warehouse, found_warehouse.second)
    assert_equal(far_warehouse, found_far_warehouse.first)

  end

  test 'Can get opening and closing times' do

    warehouse = Warehouse.create!({
                                      :title => 'Warehouse',
                                      :email => 'warehouse@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one)
                                  })
    Agenda.create!({
                       :day => Date.today.wday,
                       :opening => 1030,
                       :closing => 2220,
                       :warehouse => warehouse
                   })

    assert_equal('10:30', warehouse.today_opening_time)
    assert_equal('22:20', warehouse.today_closing_time)


  end

  test 'Warehouse opens today' do

    time_now = Time.parse('1996/01/01 12:00') #Monday
    Time.stubs(:now).returns(time_now)

    warehouse = Warehouse.create!({
                                      :title => 'Warehouse',
                                      :email => 'warehouse@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one)
                                  })
    Agenda.create!({
                       :day => time_now.wday,
                       :opening => 1030,
                       :closing => 2220,
                       :warehouse => warehouse,
                       :opens_today => true

                   })
    assert_equal(true, warehouse.opens_today)

  end

  test 'Warehouse is closed today' do
    time_now = Time.parse('1996/01/01 12:00') #Monday
    Time.stubs(:now).returns(time_now)

    warehouse = Warehouse.create!({
                                      :title => 'Warehouse',
                                      :email => 'warehouse@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one)
                                  })
    Agenda.create!({
                       :day => time_now.wday,
                       :opening => 1030,
                       :closing => 2220,
                       :warehouse => warehouse,
                       :opens_today => false

                   })
    assert_equal(false, warehouse.opens_today)
  end

  test 'Warehouse is closed today after opening hours' do
    time_now = Time.parse('1996/01/01 22:21') #Monday
    Time.stubs(:now).returns(time_now)

    warehouse = Warehouse.create!({
                                      :title => 'Warehouse',
                                      :email => 'warehouse@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one)
                                  })
    Agenda.create!({
                       :day => time_now.wday,
                       :opening => 1030,
                       :closing => 2220,
                       :warehouse => warehouse,
                       :opens_today => true
                   })
    assert_equal(false, warehouse.opens_today)
  end

  test 'Next open day is Tuesday' do
    time_now = Time.parse('1996/01/01 22:15') #Monday
    Time.stubs(:now).returns(time_now)

    warehouse = Warehouse.create!({
                                      :title => 'Warehouse',
                                      :email => 'warehouse@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one)
                                  })
    Agenda.create!({
                       :day => time_now.wday,
                       :opening => 1030,
                       :closing => 2220,
                       :warehouse => warehouse,
                       :opens_today => true
                   })

    Agenda.create!({
                       :day => time_now.wday + 1,
                       :opening => 1130,
                       :closing => 2230,
                       :warehouse => warehouse,
                       :opens_today => true
                   })

    assert_equal(2, warehouse.next_open_day)
    assert_equal('11:30', warehouse.next_open_day_opening_time)
    assert_equal('22:30', warehouse.next_open_day_closing_time)
  end


  test 'Next open day is Monday' do
    time_now = Time.parse('1996/01/07 10:00') #Sunday
    Time.stubs(:now).returns(time_now)


    warehouse = Warehouse.create!({
                                      :title => 'Warehouse',
                                      :email => 'warehouse@vyne.london',
                                      :phone => '07718225201',
                                      :address => addresses(:one)
                                  })

    Agenda.create!({
                       :day => time_now.wday,
                       :opening => 1030,
                       :closing => 2220,
                       :warehouse => warehouse,
                       :opens_today => true
                   })

    Agenda.create!({
                       :day => time_now.wday + 1,
                       :opening => 1032,
                       :closing => 2221,
                       :warehouse => warehouse,
                       :opens_today => true
                   })

    assert_equal(1, warehouse.next_open_day)
    assert_equal('10:32', warehouse.next_open_day_opening_time)
    assert_equal('22:21', warehouse.next_open_day_closing_time)
  end


  def set_open_agenda(warehouse)
    Agenda.create!({
                       :day => Time.now.wday,
                       :opening => 0000,
                       :closing => 2359,
                       :warehouse => warehouse
                   })

  end

  def set_closed_agenda(warehouse)
    Agenda.create!({
                       :day => 1.day.ago.wday,
                       :opening => 0000,
                       :closing => 2359,
                       :warehouse => warehouse
                   })

  end


  # Handy radius to polygon function from
  # https://gist.github.com/straydogstudio/4992733
  def circle_path(center, radius, segments, complete_path = false)
    # For increased accuracy, if your data is in a localized area, add the elevation in meters to r_e below:
    r_e = 6378137.0
    d2r ||= Math::PI/180
    multipliers ||= begin
      rad = 2*Math::PI/segments
      (segments + (complete_path ? 1 : 0)).times.map do |i|
        rads = rad*i
        y = Math.sin(rads)
        x = Math.cos(rads)
        [y.abs < 0.01 ? 0.0 : y, x.abs < 0.01 ? 0.0 : x]
      end
    end
    center_lat = center[:lat]
    center_lng = center[:lng]
    lat = radius/(r_e*d2r)
    lng = radius/(r_e*Math.cos(d2r*center_lat)*d2r)
    multipliers.map { |m| [center_lat + m[0]*lat, center_lng + m[1]*lng] }
  end
end