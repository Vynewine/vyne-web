require 'test_helper'
require 'webmock/minitest'

class UserMailerTest < ActionMailer::TestCase
  include UserMailer

  test 'Send order confirmation one bottle one food selection' do
    WebMock.allow_net_connect!
    order = orders(:order3)
    order.address = addresses(:three)
    order_item = OrderItem.create!(
        :order => order,
        :wine => wines(:one),
        :foods => [foods(:beef), foods(:grill_BBQ)],
        :category => categories(:house),
        :price => 15.0,
        :cost => 10.0
    )

    results = first_time_ordered(order)

    assert_equal(results[0]['status'], 'sent', 'Email status from Mandrill should be sent')
  end

  test 'Can send first time order email' do

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