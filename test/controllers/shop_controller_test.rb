require 'test_helper'
require 'sunspot/rails'
require 'stripe_mock'


class ShopControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    StripeMock.start
    # Disable mailer
    Excon.defaults[:mock] = true
    Excon.stub({}, {body: '{}', status: 200}) # stubs any request to return an empty JSON string

    @userOne = User.create!({
                                 :first_name => 'John',
                                 :last_name => 'Doe',
                                 :email => 'john@doe.vn',
                                 :mobile => '0999999',
                                 :password => 'password',
                                 :password_confirmation => 'password'
                             })

    sign_in(:user, @userOne)

    @address = Address.create!({
                                   :detail => '8A',
                                   :street => 'Pickfords Whard',
                                   :postcode => 'N1 7RJ'
                               })


    AddressesUsers.create!({
                               :user => @userOne,
                               :address => @address
                           })

    @request_data = {
        :address_id => @address.id,
        :stripeToken => 'tok_14m18t2eZvKYlo2CHKjAcAVY',
        :new_brand => '1',
        :new_card => '1111',
        :warehouses => '1,2',
        :wines => nil
    }

  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
    StripeMock.stop
  end

  test 'should create order for food matching' do

    wines = [
            {
                 :quantity => 1,
                 :food => [10, 20, 33],
                 :category => 1

            },
             {
                 :quantity => 1,
                 :food => [10, 20, 33],
                 :category => 2
             }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    payment = Payment.find_by user: @userOne
    order = Order.find_by client: @userOne

    assert_redirected_to order
    assert_response(:redirect, message = nil)
    assert_equal(order.payment, payment)
    assert_equal(order.client, @userOne)
    assert_equal(payment.user, @userOne)
    assert_equal({'warehouses'=>[1, 2]}, order.information)
    assert_equal(2, order.order_items.count, 'There should be 2 order items')
    categories = order.order_items.map { |c| c.category.id}
    assert_equal(true, (categories.include? 1) && (categories.include? 2), 'House and Reserve wines should be present on the order.')
  end

  test 'should create order for occasion matching' do

    wines = [
        {
            :quantity => 2,
            :occasion => occasions(:one).id,
            :type => types(:one).id,
            :category => 1
        }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    order = Order.find_by client: @userOne

    assert_redirected_to order
    assert_equal(occasions(:one), order.order_items[0].occasion)

  end

  test 'should create order for specific wine' do

    wines = [
        {
            :quantity => 1,
            :specificWine => 'Chateauneuf-du-Pape',
            :category => 1
        }
    ]

    @request_data[:wines] = wines.to_json

    post :create, @request_data

    order = Order.find_by client: @userOne
    assert_redirected_to order
    assert_equal('Chateauneuf-du-Pape', order.order_items[0].specific_wine)
  end



end