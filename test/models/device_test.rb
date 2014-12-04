require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'Can assign device to a warehouse' do
    warehouse = warehouses(:one)
    device = devices(:one)
    warehouse.devices << device

    saved_warehouse = Warehouse.find(warehouse)
    assert_equal(device, saved_warehouse.devices[0])
  end

  test 'Can assign mltiple devices to a warehouse' do
    warehouse = warehouses(:one)
    warehouse.devices << [devices(:one), devices(:two)]

    saved_warehouse = Warehouse.find(warehouse)
    assert_equal(2, saved_warehouse.devices.length)
  end

  test 'Can genrate random key' do
    key1 = Device.generate_key
    key2 = Device.generate_key

    assert_equal(8, key1.length)
    assert_equal(8, key2.length)
    assert(key1 != key2)

  end

  test 'Converty registration' do
    warehouse = warehouses(:one)
    warehouse.devices << [devices(:one), devices(:two)]

    saved_warehouse = Warehouse.find(warehouse)
    puts json: saved_warehouse.devices.map{ |device| device.registration_id }

  end
end