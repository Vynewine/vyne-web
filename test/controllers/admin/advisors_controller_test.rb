require 'test_helper'
require 'sunspot/rails'
require 'webmock/minitest'

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


  test 'Should update order item with chosen wine' do
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
  end



  test 'Should retrieve quotes from Shutl' do

    stub_shutl_token

    stub_request(:post, 'https://sandbox-v2.shutl.co.uk/quote_collections').
        with(:body => "{\"quote_collection\":{\"channel\":\"mobile\",\"page\":\"product\",\"session_id\":\"example123\",\"basket_value\":2000,\"pickup_location\":{\"address\":{\"postcode\":\"EC3V1LR\"}},\"delivery_location\":{\"address\":{\"postcode\":\"EC3V1LR\"}},\"products\":[{\"id\":\"wine_980190962\",\"name\":\"Bottle of wine\",\"description\":\"Bottle of wine\",\"url\":\"http://127.0.0.1/admin/wines/980190962\",\"length\":20,\"width\":15,\"height\":10,\"weight\":1,\"quantity\":1,\"price\":1000},{\"id\":\"wine_980190962\",\"name\":\"Bottle of wine\",\"description\":\"Bottle of wine\",\"url\":\"http://127.0.0.1/admin/wines/980190962\",\"length\":20,\"width\":15,\"height\":10,\"weight\":1,\"quantity\":1,\"price\":1000}]}}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 493nSJPSh9_jUsjJe3S59FNnAx3-jcKBjBBzCFM_BkF9ePKcmRPqf-XqwZ3GWdBc9M4ZH-mUb0Okn1e_WPKrwg', 'Host'=>'sandbox-v2.shutl.co.uk', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => quote_response, :headers => {})

    @order = orders(:order1)
    @wine = wines(:one)
    @warehouse = warehouses(:one)

    @order.order_items[0].wine = @wine
    @order.order_items[0].cost = 10

    @order.order_items[1].wine = @wine
    @order.order_items[1].cost = 10

    @order.warehouse = @warehouse
    @order.address = addresses(:one)
    @order.save
    @order.order_items[0].save
    @order.order_items[1].save

    post :choose, {:order => @order.id}

    assert_response(:success)
    assert(@response.body.include?(@id1), 'Response should contains id1')
    assert(@response.body.include?(@id2), 'Response should contains id2')
  end

  test 'Should maintain price from original order after advise is made' do
    @order = orders(:order1)
    @wine = wines(:three)
    @warehouse = warehouses(:one)
    order_item = @order.order_items[0]
    order_item.category = categories(:reserve)

    #This is Reserve (£20) wine but we're simulating £5 discount
    order_item.price = 15.00
    order_item.save

    post :update, {'wine-id' => @wine.id, 'warehouse-id' => @warehouse.id, 'id' => order_item.id }

    order_item = OrderItem.find(@order.order_items[0].id)


    assert_equal(15.00.to_s, order_item.price.to_s, 'Price should stay the same after wine selection')

  end

  def quote_response
    @id1 = '5447e3e3e4b0b774cd5673eb-1413998439'
    @id2 = '5447e3e3e4b0b774cd5673eb-1414002039'
    '{
                 "quote_collection":{
                    "id":"5447e3e3e4b0b774cd5673eb",
                    "created_at":"2014-10-22T18:05+01:00",
                    "time_zone":"Europe/London",
                    "distance":5.7,
                    "no_coverage":false,
                    "shop_and_pay_by_card":false,
                    "best_quote":{
                       "id":"5447e3e3e4b0b774cd5673eb-asap",
                       "merchant_price":1162,
                       "customer_price":1394,
                       "customer_price_ex_tax":1161,
                       "vehicle":"motorbike",
                       "pickup_start":"2014-10-22T18:20+01:00",
                       "pickup_finish":"2014-10-22T18:50+01:00",
                       "delivery_start":"2014-10-22T18:20+01:00",
                       "delivery_finish":"2014-10-22T20:35+01:00",
                       "valid_until":"2014-10-22T18:20+01:00",
                       "delivery_promise":135,
                       "delivery_promise_text":"delivery within 2 hours and 15 minutes for &pound;13.94"
                    },
                    "quotes":[
                       {
                          "id":"' + @id1 + '",
                          "merchant_price":1162,
                          "customer_price":1394,
                          "customer_price_ex_tax":1161,
                          "vehicle":"motorbike",
                          "pickup_start":"2014-10-22T18:30+01:00",
                          "pickup_finish":"2014-10-22T20:00+01:00",
                          "delivery_start":"2014-10-22T20:00+01:00",
                          "delivery_finish":"2014-10-22T21:00+01:00",
                          "valid_until":"2014-10-22T18:30+01:00"
                       },
                       {
                          "id":"' + @id2 + '",
                          "merchant_price":1348,
                          "customer_price":1617,
                          "customer_price_ex_tax":1347,
                          "vehicle":"small_van",
                          "pickup_start":"2014-10-22T19:30+01:00",
                          "pickup_finish":"2014-10-22T21:00+01:00",
                          "delivery_start":"2014-10-22T21:00+01:00",
                          "delivery_finish":"2014-10-22T22:00+01:00",
                          "valid_until":"2014-10-22T19:30+01:00"
                       }
                    ]
                 }
              }'
  end

end
