require 'test_helper'
require 'sunspot/rails'

class Admin::AdvisorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)

    @admin = users(:admin)
    sign_in(:user, @admin)


  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  #TODO: This test should verify parameters sent to solr and mock some return values
  #TODO: Look here for examples: https://github.com/pivotal/sunspot_matchers
  test 'should get results' do

    warehouse_one = warehouses(:one)
    warehouse_two = warehouses(:two)

    # get :results, {:keywords => 'red',
    #                :order_id => orders(:order1).id,
    #                :warehouses => warehouse_one.id.to_s + ',' + warehouse_two.id.to_s,
    #                :single => 'false',
    #                :vegan => 'false',
    #                :organic => 'false',
    #                :categories => [categories(:house).id],
    #                :format => :json
    # }
    # puts @results
  end

  test 'filter wine search' do

    wines = [wines(:one), wines(:two)]
    order_info = { "warehouses" => [{ "id" => warehouses(:one).id, "distance" => 2.123}, { "id" => warehouses(:two).id, "distance" => 1.123}]}

    # warehouse is, wine name, quantity, price

    results_wines = []

    order_info['warehouses'].each{ |warehouse|

      warehouse_id =  warehouse['id']

      wines.each{|wine|
        wine.inventories.select{ |inv|
          if inv.warehouse.id == warehouse_id
            results_wines << {
                :name => wine.name,
                :cost => inv.cost.to_s,
                :category => inv.category.name + ' - £' + inv.category.price.to_s,
                :warehouse => inv.warehouse.id,
                :warehouse_distance => warehouse['distance'],
                :compositions => wine.compositions.map { |c| { :name => c.grape.name, :quantity => c.quantity }}
            }
          end
        }
      }

    }

    puts json: results_wines

    #puts json: @wines.select{ |wine| wine.vintage == 2007 }
    # puts @wines.each{ |wine| wine.inventories.each{ |inv| inv.warehouse.id } }
  end

  test 'should update order item with chosen wine' do
    @order = orders(:order1)
    @wine = wines(:one)
    @warehouse = warehouses(:one)
    post :update, {'wine-id' => @wine.id, 'warehouse-id' => @warehouse.id, 'id' => @order.order_items[0].id }

    order_item = OrderItem.find(@order.order_items[0].id)
    inventory = Inventory.find_by(:warehouse => @warehouse, :wine => @wine)

    assert(!order_item.wine.nil?, 'Wine should be assigned to order item.')
    assert_equal(@wine.id, order_item.wine.id, 'Wine doesn\'t match wine on order item.' )
    assert(!order_item.order.warehouse.nil?, 'Warehouse should be assigned to the order')
    assert_equal(@warehouse.id, order_item.order.warehouse.id, 'Warehouse doesn\'t match')
    assert(!order_item.order.advisor.nil?, 'Advisor should be assigned to the order')
    assert_equal(@admin, order_item.order.advisor, 'Advisor doesn\'t match')
    assert(!order_item.cost.nil?, 'Wine cost should be present on the order item')
    assert_equal(order_item.cost, inventory.cost, 'Cost for wine should match inventory cost')
    assert(!order_item.price.nil?, 'Wine price should be present on the order item')
    assert_equal(order_item.price, order_item.category.price, 'Price should match price from category')
  end
end
