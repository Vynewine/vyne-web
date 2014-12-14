require 'test_helper'

class StripeHelperTest < ActiveSupport::TestCase

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    WebMock.allow_net_connect!
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'this can be tested' do
    Stripe.api_key = Rails.application.config.stripe_key

    customer = Stripe::Customer.retrieve('cus_592ZmyKJtx6uJD')
    customer.cards.create({
                              :card => 'tok_14ykn1242nQKOZxvhfHU1tob'
                                  # {
                                  #     :number => '4000000000000002',
                                  #     :exp_month => '12',
                                  #     :exp_year => '14',
                                  #     :cvc => '123'
                                  # }
                          })

    puts json: new_customer

  end

  test 'Will handle exceptions when creating customer' do
    stripe_key = Rails.application.config.stripe_key
    Rails.application.config.stripe_key = nil
    client = users(:one)
    response = StripeHelper.create_customer(client)
    assert_equal(2, response[:errors].count)
    assert_equal('Error occurred while creating customer with Stripe', response[:errors][0])

    #Reset Stripe Key for all other tests.
    Rails.application.config.stripe_key = stripe_key
  end

  test 'Will handle exceptions when retrieving customer' do
    stripe_key = Rails.application.config.stripe_key
    Rails.application.config.stripe_key = nil
    client = users(:one)
    response = StripeHelper.get_customer(client)
    assert_equal(2, response[:errors].count)
    assert_equal('Error occurred while retrieving customer from Stripe', response[:errors][0])

    #Reset Stripe Key for all other tests.
    Rails.application.config.stripe_key = stripe_key
  end

  test 'Will handle exceptions when creating card for customer' do
    Stripe.api_key = Rails.application.config.stripe_key
    customer = Stripe::Customer.retrieve('cus_592ZmyKJtx6uJD')
    stripe_key = Rails.application.config.stripe_key
    Rails.application.config.stripe_key = nil
    response = StripeHelper.create_card(customer, '')
    assert_equal(2, response[:errors].count)
    assert_equal('Error occurred while creating card for customer', response[:errors][0])

    #Reset Stripe Key for all other tests.
    Rails.application.config.stripe_key = stripe_key
  end

  test 'Can charge the card' do
    results = StripeHelper.charge_card(2000, 'card_14yNrx242nQKOZxvq4IBG6qB', 'cus_58fCEwXl68Xknn')
    assert(results[:data].paid)
    assert(!results[:data].blank?)
  end

  test 'Can handle integer charge error' do
    results = StripeHelper.charge_card(20.00, 'card_14yNrx242nQKOZxvq4IBG6qB', 'cus_58fCEwXl68Xknn')
    assert(!results[:errors].blank?)
    assert_equal('Invalid integer: 20.0', results[:errors][0])
  end

  test 'Can handle API charge error' do
    stripe_key = Rails.application.config.stripe_key
    Rails.application.config.stripe_key = nil
    results = StripeHelper.charge_card(20.00, 'card_14yNrx242nQKOZxvq4IBG6qB', 'cus_58fCEwXl68Xknn')
    assert(!results[:errors].blank?)
    assert(results[:errors][0].include?'No API key provided.')

    #Reset Stripe Key for all other tests.
    Rails.application.config.stripe_key = stripe_key
  end

end