require 'test_helper'
require 'webmock/minitest'

class UserMailerTest < ActionMailer::TestCase
  include UserMailer

  def order_one_bottle
    @order = orders(:order3)
    @order.warehouse = warehouses(:one)
    @order.address = addresses(:three)
    order_item = OrderItem.create!(
        :order => @order,
        :wine => wines(:one),
        :category => categories(:house),
        :price => 15.0,
        :cost => 10.0
    )
    @order
  end

  def order_two_bottles
    @order = orders(:order3)
    @order.warehouse = warehouses(:one)
    @order.address = addresses(:three)
    OrderItem.create!(
        :order => @order,
        :wine => wines(:one),
        :category => categories(:house),
        :price => 15.0,
        :cost => 10.0
    )

    OrderItem.create!(
        :order => @order,
        :wine => wines(:two),
        :category => categories(:reserve),
        :price => 20.0,
        :cost => 12.0
    )
    @order
  end

  test 'Send order receipt' do
    WebMock.allow_net_connect!
    order_two_bottles

    @order.order_items[0].quantity = 1
    @order.order_items[0].wine = wines(:one)
    @order.order_items[1].quantity = 1
    @order.order_items[1].wine = wines(:two)
    @order.payment = payments(:one)

    results = UserMailer.order_receipt(@order)

    puts json: results
  end

  test 'Send order receipt for promo order' do
    WebMock.allow_net_connect!
    order = orders(:promo_order)
    results = UserMailer.order_receipt(order)
    puts json: results
  end


  test 'Merchant promo order confirmation' do
    WebMock.allow_net_connect!
    order = orders(:promo_order)
    result = UserMailer.merchant_order_confirmation(order)
    puts json: result
  end

  test 'Send order cancellation email to the client' do
    WebMock.allow_net_connect!
    order = orders(:promo_order)
    result = UserMailer.order_cancellation(order)
    puts json: result
  end


  test 'Send order confirmation one bottle one food selection' do
    WebMock.allow_net_connect!

    order_one_bottle

    order_item = @order.order_items[0]

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item => order_item)

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation one bottle occasion medium red' do
    WebMock.allow_net_connect!

    order_one_bottle

    order_item = @order.order_items[0]

    order_item.occasion = occasions(:two)
    order_item.type = types(:two)
    order_item.save

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end


  test 'Send order confirmation one bottle specific wine' do
    WebMock.allow_net_connect!

    order_one_bottle

    order_item = @order.order_items[0]

    order_item.specific_wine = 'I Like it bold!'
    order_item.save

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation one bottle occasion rich white' do
    WebMock.allow_net_connect!

    order = order_two_bottles

    order.order_items[0].occasion = occasions(:two)
    order.order_items[0].type = types(:two)
    order.order_items[0].save

    order.order_items[1].occasion = occasions(:two)
    order.order_items[1].type = types(:two)
    order.order_items[1].save

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation one bottle two food selections' do
    WebMock.allow_net_connect!

    order_one_bottle

    order_item = @order.order_items[0]

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item => order_item)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item => order_item)
    FoodItem.create!(:food => foods(:pasta), :order_item => order_item)

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation two bottles two three selections' do
    WebMock.allow_net_connect!

    order = order_two_bottles

    order_item1 = order.order_items[0]
    order_item2 = order.order_items[1]

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item => order_item1)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item => order_item1)
    FoodItem.create!(:food => foods(:vanilla_caramel), :order_item => order_item1)

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item => order_item2)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item => order_item2)
    FoodItem.create!(:food => foods(:vanilla_caramel), :order_item => order_item2)

    results = first_time_ordered(order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  def stub_mandrill(template_name, response, message, status)
    stub_request(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json').
        with(:body => {
        :template_name => template_name,
        :template_content => nil,
        :message => message,
        :async => false,
        :ip_pool => nil,
        :send_at => nil,
        :key => 'ipcLBLgQRHya2q3jvpPQsw'},
             :headers => {'Content-Type' => 'application/json', 'Host' => 'mandrillapp.com:443', 'User-Agent' => 'excon/0.39.6'}).
        to_return(:status => status, :body => response, :headers => {})
  end

  def success_response
    '[
      {"email":"recipient.email@example.com",
        "status":"sent",
        "reject_reason":"",
        "_id":"abc123abc123abc123abc123abc123"}
      ]'
  end

  def failed_response
    '{
      "status": "error",
      "code": 12,
      "name": "Unknown_Template",
      "message": "No such template \"orderplaced-1tochv1\""
    }'
  end
end