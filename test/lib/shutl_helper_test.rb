require 'test_helper'

class ShutlHelperTest < ActiveSupport::TestCase
  include ShutlHelper

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    WebMock.allow_net_connect!
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can handle store setup errors' do

    @address = Address.create!({
                                   :line_1 => 'Street 1',
                                   :line_2 => 'Street 2',
                                   :postcode => 'bad postcode'
                               })

    @warehouse = Warehouse.create!({
                                       :title => 'Store 1',
                                       :email => 'store',
                                       :phone => 'bad phone',
                                       :active => true,
                                       :address => @address
                                   })

    results = add_warehouse_to_shutl(@warehouse)
    puts json: results

  end

end