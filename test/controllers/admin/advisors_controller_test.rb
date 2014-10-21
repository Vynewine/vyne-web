require 'test_helper'
require 'sunspot/rails'

class Admin::AdvisorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @admin = users(:admin)
    sign_in(:user, @admin)
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  #TODO: This test sjould verify parameters sent to solr and mock some return values
  #TODO: Look here for examples: https://github.com/pivotal/sunspot_matchers
  test 'should get results' do

    warehouse_one = warehouses(:one)
    warehouse_two = warehouses(:two)

    get :results, {:keywords => 'red',
                   :warehouses => warehouse_one.id.to_s + ',' + warehouse_two.id.to_s,
                   :single => 'false',
                   :vegan => 'false',
                   :organic => 'false',
                   :categories => [categories(:house).id],
                   :format => :json
    }
    puts @results
  end
end
