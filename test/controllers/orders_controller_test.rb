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

    @userTwo = User.create!({
                                :first_name => 'John',
                                :last_name => 'Bro',
                                :email => 'john2@doe.vn',
                                :mobile => '0999999',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    @userOne.add_role(roles(:client))

    sign_in(:user, @userOne)


    @order = Order.create!({
                                :client_id => @userOne.id,
                                :status_id => statuses(:two).id
                            })

  end

  teardown do
    Sunspot.session = Sunspot.session.original_session
  end

  test 'should get index' do
    get :index
    assert_response :success
    # assert_not_nil assigns(:orders)
  end

  test 'should show order' do
    get :show, id: @order.id
    assert_response :success
    assert_match(/#{@order.id}/, @response.body)
    assert_match(/#{@order.status.label}/, @response.body)
  end

  test 'will not show order created by different user' do
    sign_out(:user)
    sign_in(:user, @userTwo)
    get :show, id: @order.id
    assert_response :forbidden
  end

end
