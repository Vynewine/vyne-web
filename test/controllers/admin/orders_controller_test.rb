require 'test_helper'

class Admin::OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    @admin = users(:admin)
    sign_in(:user, @admin)

    @userOne = User.create!({
                                :first_name => 'John',
                                :last_name => 'Doe',
                                :email => 'john@vyne.london'
                            })

  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can charge order' do

  end

end