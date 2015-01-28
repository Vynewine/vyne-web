require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    @user = users(:supplier)
    sign_in(:user, @user)
    @device_key = '12345'
    cookies[:device] = @device_key
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  #Device Tests

  test 'User can not access device if not registered with the same warehouse' do
    @user.warehouses << warehouses(:one)

    Device.create!({
                       :key => @device_key,
                       :warehouse => warehouses(:two)
                   })

    user_can_access_device = @controller.send(:user_can_access_device)
    assert(!user_can_access_device)
  end

  test 'User can not access device if device not registered with a warehouse' do
    @user.warehouses << warehouses(:one)

    Device.create!({
                       :key => @device_key
                   })

    user_can_access_device = @controller.send(:user_can_access_device)
    assert(!user_can_access_device)
  end

  test 'User can access the device' do

    warehouse = warehouses(:one)
    @user.warehouses << [warehouse]

    Device.create!({
                       :key => @device_key,
                       :warehouse => warehouse
                   })

    user_can_access_device = @controller.send(:user_can_access_device)
    assert(user_can_access_device)

  end

  test 'User can not access device if not in Supplier group' do
    @user = users(:client)
    sign_in(:user, @user)

    warehouse = warehouses(:one)
    @user.warehouses << warehouse

    Device.create!({
                       :key => @device_key,
                       :warehouse => warehouse
                   })

    user_can_access_device = @controller.send(:user_can_access_device)
    assert(!user_can_access_device)
  end

end