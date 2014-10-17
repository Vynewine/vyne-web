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

  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
    StripeMock.stop
  end

  test 'should create order' do

    wines = [{
                 :quantity => 1,
                 :specificWine => 'Chateauneuf-du-Pape',
                 :food => [1, 3, 4],
                 :occasion => occasions(:one),
                 :type => types(:one)

             }, {
                 :quantity => 2,
                 :specificWine => 'Chateauneuf-du-Pape',
                 :food => [1, 3, 4],
                 :occasion => occasions(:two),
                 :type => types(:two)
             }
    ]

    post :create, {
        :address_id => @address.id,
        :stripeToken => 'tok_14m18t2eZvKYlo2CHKjAcAVY',
        :new_brand => '1',
        :new_card => '1111',
        :warehouses => '1,2',
        :wines => wines.to_json
    }

    payment = Payment.find_by user: @userOne
    order = Order.find_by client: @userOne

    assert_redirected_to order
    assert_response(:redirect, message = nil)
    assert_equal(order.payment, payment)
    assert_equal(order.client, @userOne)
    assert_equal(payment.user, @userOne)
    assert_equal(order.info, '{"warehouses":[1,2]}')

  end

end