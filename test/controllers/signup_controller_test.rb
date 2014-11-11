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

  test 'Should create user' do
    post :create, :user => {
        :first_name => 'John',
        :email => 'test@vinz.com',
        :password => 'password'
    }
    assert_response :success
  end

  test 'Should not create user with out password' do
    post :create, :user => {
        :first_name => 'John',
        :email => 'test@vinz.com'
    }
    assert_response 422
    body = JSON.parse(@response.body)
    assert_equal('Password is required.', body["errors"][0], 'Password validation should fail')
  end

  test 'Mobile is required' do

    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    sign_in(:user, new_user)

    post :address, {:address_s => 'Main Street',
                    :address_p => 'N1 7RJ',
                    :new_address => 'true'
    }
    assert_response 422
    body = JSON.parse(@response.body)

    assert_equal('Mobile can\'t be blank', body["errors"][0], 'Mobile is required')
  end

  test 'Valid mobile is required' do

    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    sign_in(:user, new_user)

    post :address, {:address_s => 'Main Street',
                    :address_p => 'N1 7RJ',
                    :mobile => '999999',
                    :new_address => 'true'
    }
    assert_response 422
    body = JSON.parse(@response.body)
    assert_equal('Mobile number is not valid', body["errors"][0], 'Valid mobile is required')
  end

  test 'Should create use address and mobile' do

    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    sign_in(:user, new_user)

    post :address, {:address_s => 'Main Street',
                    :address_p => 'N1 7RJ',
                    :mobile => '+44 077 1822 5201',
                    :new_address => 'true'
    }

    user = User.find(new_user.id)

    assert_response :success
    assert @response.body.include? 'Main Street'
    assert_equal('N1 7RJ', user.addresses[0].postcode, 'User postcode not correct')
    assert_equal('7718225201', user.mobile, 'User mobile is not correct')
  end

  test 'Should update just created address if address id present' do
    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    new_address = Address.create!({
                                      :street => 'Street1',
                                      :postcode => 'N17RJ'
                                  })

    AddressesUsers.create!({
                               :user => new_user,
                               :address => new_address
                           })

    sign_in(:user, new_user)

    assert_equal('N17RJ', new_user.addresses[0].postcode, 'User postcode not correct')

    post :address, {
        :address_id => new_address.id,
        :address_s => 'Main Street',
        :address_p => 'N2 7RJ',
        :mobile => '+44 072 1822 5201',
        :new_address => 'true'
    }

    user = User.find(new_user.id)

    assert_response :success
    assert @response.body.include? 'Main Street'
    assert_equal('N2 7RJ', user.addresses[0].postcode, 'User postcode not correct')
    assert_equal(1, user.addresses.count, 'User should have only one address')
    assert_equal('7218225201', user.mobile, 'User mobile is not correct')

  end

  test 'Should create new address and add new association' do
    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :password => 'password',
                                :password_confirmation => 'password'
                            })

    new_address = Address.create!({
                                      :street => 'Street1',
                                      :postcode => 'N17RJ'
                                  })

    AddressesUsers.create!({
                               :user => new_user,
                               :address => new_address
                           })

    sign_in(:user, new_user)

    assert_equal('N17RJ', new_user.addresses[0].postcode, 'User postcode not correct')

    post :address, {
        :address_s => 'Main Street 2',
        :address_p => 'N2 7RJ',
        :mobile => '+44 072 1822 5201',
        :new_address => 'true'
    }

    user = User.find(new_user.id)

    new_address = user.addresses.select { |a| a.street == 'Main Street 2' }.first

    assert_response :success
    assert @response.body.include? 'Main Street 2'
    assert_equal('N2 7RJ', new_address.postcode, 'User postcode not correct')
    assert_equal(2, user.addresses.count, 'User should have only one address')
    assert_equal('7218225201', user.mobile, 'User mobile is not correct')

  end

  test 'Should use existing address' do
    new_user = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@doe.vn',
                                :password => 'password',
                                :mobile => '7718225201'
                            })

    new_address = Address.create!({
                                      :street => 'Street1',
                                      :postcode => 'N1 7RJ'
                                  })

    AddressesUsers.create!({
                               :user => new_user,
                               :address => new_address
                           })

    sign_in(:user, new_user)

    post :address, {
        :address_id => new_address.id
    }

    user = User.find(new_user.id)

    assert_equal(user.mobile, '7718225201')
    assert_equal(user.first_name, 'John')
    assert_equal(1, user.addresses.count, 'User should have only one address')
    assert_equal('N1 7RJ', user.addresses[0].postcode, 'User should have only one address')

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

  test 'Shoiuld validate address and mobile' do

  end

  test 'email validation' do
    value = 'jakub.borys.@gmail.co'
    assert(value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 'Not a valid email')
  end

  test 'phone validation' do
    number = '+447718225201'

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should strip leading +44')

    number = '00447718225201'

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should strip leading 0044')

    number = '77 1822 5201'

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should strip spaces')

    number = '77-1822-5201'

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should strip dashes')

    number = ' "77.1822\'5201 '

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should strip parenthesis and full stops')

    number = '07718225201'

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should strip leading 0')

    number = '771822520'

    assert_equal(nil, @controller.send(:validate_uk_phone, number), 'Mobile number should be 10 digits')

    number = '8718225201'

    assert_equal(nil, @controller.send(:validate_uk_phone, number), 'Mobile number should be 9 digits')

    number = '+44 077 1822 5201'

    assert_equal('7718225201', @controller.send(:validate_uk_phone, number), 'Should work')
  end


end
