require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end


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

  test 'Can assign roles to the user' do
    user = User.create!({
                     :first_name => 'Mike',
                     :last_name => 'Judge',
                     :email => 'mike@vyne.london'
                 })

    user.add_role :client

    saved_user = User.find(user)

    assert_equal(user, saved_user)
    assert(saved_user.has_role? :client)
    assert_equal(1, saved_user.roles.length)
  end
end