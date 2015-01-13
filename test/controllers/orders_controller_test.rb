require 'test_helper'
require 'sunspot/rails'
require 'json'
require 'pp'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)

    @userOne = User.create!({
                                 :first_name => 'John',
                                 :last_name => 'Doe',
                                 :email => 'john@doe.vn',
                                 :mobile => '0999999',
                                 :password => 'password',
                                 :password_confirmation => 'password'
                             })

    @userOne.add_role(roles(:client))

    sign_in(:user, @userOne)


    @order = Order.create!({
                                :client_id => @userOne.id
                            })

  end

  teardown do
    Sunspot.session = Sunspot.session.original_session
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should show order' do
    get :show, id: @order.id
    assert_response :success
  end

  test 'will not show order created by different user' do
    sign_out(:user)
    sign_in(:user, @userTwo)
    get :show, id: @order.id
    assert_response :forbidden
  end

  test 'sub dates' do

    advised_at = Time.now.utc - 20.seconds
    # puts advised_at
    # puts advised_at - 5.minutes
    # puts (Time.now.utc - advised_at).seconds.to_i
    # puts 5.minutes.seconds


    time_out = Time.now.utc - 5.minutes
    if advised_at > time_out
      puts (advised_at - time_out).seconds.to_i
    else
      puts 0
    end

  end

end
