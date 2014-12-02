require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'Can add User to Warehouse' do
    warehouse = warehouses(:one)
    user = users(:one)
    warehouse.users << user
    warehouse.save

    saved_warehouse = Warehouse.find(warehouse)
    assert_equal(user, saved_warehouse.users[0])
    assert_equal(1, saved_warehouse.users.length)
  end

  test 'Can multiple Users to Warehouse' do
    warehouse = warehouses(:one)
    warehouse.users << [users(:one), users(:two)]
    warehouse.save

    saved_warehouse = Warehouse.find(warehouse)
    assert_equal(2, saved_warehouse.users.length)
  end
end