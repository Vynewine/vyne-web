require 'test_helper'
require 'sunspot/rails'

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
end
