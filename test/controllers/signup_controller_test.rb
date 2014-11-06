require 'test_helper'
require 'sunspot/rails'
require 'json'

class SignupControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'should create user' do
    post :create, :user => {
        :first_name => 'John',
        :last_name => 'Doe',
        :email => 'test@vinz.com',
        :mobile => '099999999999',
        :password => 'password',
        :password_confirmation => 'password'
    }
    assert_response :success
  end

  test 'should not create user with not matching passwords' do
    post :create, :user => {
        :first_name => 'John',
        :last_name => 'Doe',
        :email => 'test@vinz.com',
        :mobile => '099999999999',
        :password => 'password',
        :password_confirmation => 'password_not_match'
    }
    assert_response 422
    body = JSON.parse(@response.body)
    assert_equal("Password confirmation doesn't match Password", body["errors"][0], 'Password validation should fail')
  end

  test 'should create address' do

    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :mobile => '0999999',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    sign_in(:user, new_user)
    post :address, {:address_d => '8A', :address_s => 'Main Street', :address_p => 'N1 7RJ'}
    assert_response :success
    assert @response.body.include? '8A'
    assert_equal('N17RJ', new_user.addresses[0].postcode, 'User postcode not correct')
  end

  test 'Should create mailing list entry for users not in the area' do
    WebMock.allow_net_connect!

    post :mailing_list_signup, {
        :email => 'jakub.borys@gmail.com',
        :postcode => 'n1 7rj',
        :distances => '[{"m":11423,"mi":7.098},{"m":15467,"mi":9.611},{"m":11614,"mi":7.217}]',
        :list_key => 'coming-soon'
    }

    response = JSON.parse(@response.body)

    subscribers = Subscriber.all

    assert_equal(1, subscribers.length, 'There should only be one subscriber.')
    assert_equal(response['email'], 'jakub.borys@gmail.com', 'Email of new subscriber should match')
    assert_equal(subscribers[0].mailing_list, mailing_lists(:coming_soon), 'Subscriber should belong to coming_soon list')
  end

  test 'Should create Mailchimp subscriber if no distance id provided or wholesalers are closed' do
    WebMock.allow_net_connect!

    post :mailing_list_signup, {
        :email => 'jakub.borys@gmail.com',
        :postcode => 'n1 7rj',
        :list_key => 'coming-soon',
        :closed => true
    }

    response = JSON.parse(@response.body)

    subscribers = Subscriber.all

    assert_equal(1, subscribers.length, 'There should only be one subscriber.')
    assert_equal(response['email'], 'jakub.borys@gmail.com', 'Email of new subscriber should match')
    assert_equal(subscribers[0].mailing_list, mailing_lists(:coming_soon), 'Subscriber should belong to coming_soon list')
  end

  test 'Should validate email' do
    post :mailing_list_signup, {
        :email => 'jakub.borys@gmail',
        :list_key => 'coming-soon'
    }

    response = JSON.parse(@response.body)

    assert(!response['errors'].blank?, 'Errors should be filled in')
    assert_equal('Please enter valid email address.', response['errors'][0], 'Should catch bad email.')

  end

  test 'email validation' do
    value = 'jakub.borys.@gmail.co'
    assert(value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 'Not a valid email')
  end

end
