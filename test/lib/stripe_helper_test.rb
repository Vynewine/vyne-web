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

end