require 'test_helper'

class Admin::DevicesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Supplier can register a device' do


    @supplier = users(:supplier)
    sign_in(:user, @supplier)
    device = devices(:one)

    post :register , { :key => device.key, :registration_id => '123'}

    assert_equal('200', @response.code)

  end

  test 'Client can not register device' do
    @client = users(:client)
    sign_in(:user, @client)
    device = devices(:one)

    post :register , { :key => device.key, :registration_id => '123'}

    assert_equal('403', @response.code)
  end

  test 'Supplier can not see all device' do
    @supplier = users(:supplier)
    sign_in(:user, @supplier)

    get :index

    assert_equal('403', @response.code)
  end

end
