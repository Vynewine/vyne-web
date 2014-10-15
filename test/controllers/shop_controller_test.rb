require 'test_helper'
require 'sunspot/rails'
require 'stripe_mock'


class ShopControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    StripeMock.start

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
    post :create, {
        :address_id => @address.id,
        :stripeToken => 'tok_14m18t2eZvKYlo2CHKjAcAVY',
        :new_brand => '1',
        :new_card => '1111'
    }

    payment = Payment.find_by user: @userOne
    order = Order.find_by client: @userOne

    assert_redirected_to order
    assert_response(:redirect, message = nil)
    assert_equal(order.payment, payment)
    assert_equal(order.client, @userOne)
    assert_equal(payment.user, @userOne)

  end

end