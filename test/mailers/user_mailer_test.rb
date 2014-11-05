require 'test_helper'
require 'webmock/minitest'

class UserMailerTest < ActionMailer::TestCase
  include UserMailer

  def order_one_bottle
    @order = orders(:order3)
    @order.address = addresses(:three)
    order_item = OrderItem.create!(
        :order => @order,
        :wine => wines(:one),
        :category => categories(:house),
        :price => 15.0,
        :cost => 10.0
    )
  end

  def order_two_bottles
    @order = orders(:order3)
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
        :wine => wines(:one),
        :category => categories(:reserve),
        :price => 20.0,
        :cost => 12.0
    )
    @order
  end

  test 'Send order confirmation one bottle one food selection' do
    WebMock.allow_net_connect!

    order_item = order_one_bottle

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation one bottle occasion medium red' do
    WebMock.allow_net_connect!

    order_item = order_one_bottle

    order_item.occasion = occasions(:two)
    order_item.type = types(:two)
    order_item.save

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end


  test 'Send order confirmation one bottle specific wine' do
    WebMock.allow_net_connect!

    order_item = order_one_bottle

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

  test 'template testing occsstion' do

    order = order_two_bottles

    order.order_items[0].occasion = occasions(:two)
    order.order_items[0].type = types(:two)
    order.order_items[0].save

    order.order_items[1].occasion = occasions(:two)
    order.order_items[1].type = types(:two)
    order.order_items[1].save

    template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
    puts template.result(binding)

  end

  test 'template testing foods' do

    order_item = order_one_bottle

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)
    FoodItem.create!(:food => foods(:pasta), :order_item =>  order_item)
    order = order_item.order
    template = ERB.new(File.read(Rails.root.join('app', 'views', 'user_mailer', 'order_items.erb')))
    puts template.result(binding)

  end

  test 'Send order confirmation one bottle two food selections' do
    WebMock.allow_net_connect!

    order_item = order_one_bottle

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)
    FoodItem.create!(:food => foods(:pasta), :order_item =>  order_item)

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation one bottle two three selections' do
    WebMock.allow_net_connect!

    order_item = order_one_bottle

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item =>  order_item)
    FoodItem.create!(:food => foods(:vanilla_caramel), :order_item =>  order_item)

    results = first_time_ordered(@order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Send order confirmation two bottles two three selections' do
    WebMock.allow_net_connect!

    order = order_two_bottles

    order_item1 = order.order_items[0]
    order_item2 = order.order_items[1]

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item =>  order_item1)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item =>  order_item1)
    FoodItem.create!(:food => foods(:vanilla_caramel), :order_item =>  order_item1)

    FoodItem.create!(:food => foods(:beef), :preparation => preparations(:grill_BBQ), :order_item =>  order_item2)
    FoodItem.create!(:food => foods(:lobster_shellfish), :preparation => preparations(:grill_BBQ), :order_item =>  order_item2)
    FoodItem.create!(:food => foods(:vanilla_caramel), :order_item =>  order_item2)

    results = first_time_ordered(order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end


  test 'Can send first time order email' do

    WebMock.allow_net_connect!

    order = orders(:order1)


    message = {
        :to => [
            {
                :email => order.client.email,
                :name => order.client.first_name}
        ],
        :merge_vars => [
            {
                :rcpt => order.client.email,
                :vars => [
                    {
                        :name => 'NAME',
                        :content => order.client.first_name}
                ]
            }
        ]}

    stub_mandrill('orderplaced-1tochv1', success_response, message, 200)


    results = first_time_ordered(order)
    assert_equal(results.kind_of?(Array), true, 'Bad response from the Mandrill')
    assert_equal('sent', results[0]['status'], msg = "Can't send first_time_ordered email")
  end

  test 'Will handle error response' do

    order = orders(:order1)
    order.address = addresses(:one)

    message = {
        :to => [
            {
                :email => order.client.email,
                :name => order.client.first_name}
        ],
        :merge_vars => [
            {
                :rcpt => order.client.email,
                :vars => [
                    {
                        :name => 'NAME',
                        :content => order.client.first_name}
                ]
            }
        ]}

    stub_mandrill('orderplaced-1tochv1', failed_response, message, 500)

    results = first_time_ordered(order)
    puts json: results
    assert(results.blank?, 'Results during error will be blank')

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