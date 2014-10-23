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

  test 'Filter wine search' do

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
    assert(!order_item.price.nil?, 'Wine price should be present on the order item')
    assert_equal(order_item.price, order_item.category.price, 'Price should match price from category')
  end

  test 'Should retrieve quotes from Shutl' do

    # stub_request(:post, 'https://sandbox-v2.shutl.co.uk/token').
    #     with(:body => {
    #     'client_id'=>'HnnFB2UbMlBXdD9h4UzKVQ==',
    #     'client_secret'=>'pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A==',
    #     'grant_type'=>'client_credentials'
    # }, :headers => {
    #     'Accept'=>'*/*',
    #     'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    #     'Content-Type'=>'application/x-www-form-urlencoded',
    #     'Host'=>'sandbox-v2.shutl.co.uk',
    #     'User-Agent'=>'Ruby'
    # }).to_return(:status => 200, :body => @token_response, :headers => {})

    stub_request(:post, "https://sandbox-v2.shutl.co.uk/token").
        with(:body => {"client_id"=>"HnnFB2UbMlBXdD9h4UzKVQ==", "client_secret"=>"pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A==", "grant_type"=>"client_credentials"},
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'sandbox-v2.shutl.co.uk', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => '{"access_token":"493nSJPSh9_jUsjJe3S59FNnAx3-jcKBjBBzCFM_BkF9ePKcmRPqf-XqwZ3GWdBc9M4ZH-mUb0Okn1e_WPKrwg","token_type":"bearer","expires_in":788939999}', :headers => {})

    @order = orders(:order1)
    @wine = wines(:one)
    @warehouse = warehouses(:one)
    puts json: @warehouse.address.postcode
    @order.order_items[0].wine = @wine
    @order.order_items[1].wine = @wine
    @order.warehouse = @warehouse
    @order.save
    @order.order_items[0].save
    @order.order_items[1].save

    post :choose, {:order => @order.id}

    puts @response.body
  end
end

#@token_response = '{"access_token":"493nSJPSh9_jUsjJe3S59FNnAx3-jcKBjBBzCFM_BkF9ePKcmRPqf-XqwZ3GWdBc9M4ZH-mUb0Okn1e_WPKrwg","token_type":"bearer","expires_in":788939999}'
#@token_response = {"access_token" => "493nSJPSh9_jUsjJe3S59FNnAx3-jcKBjBBzCFM_BkF9ePKcmRPqf-XqwZ3GWdBc9M4ZH-mUb0Okn1e_WPKrwg","token_type" => "bearer","expires_in" =>788939999}
@quote_response = '{
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
            "id":"5447e3e3e4b0b774cd5673eb-1413998439",
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
            "id":"5447e3e3e4b0b774cd5673eb-1414002039",
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