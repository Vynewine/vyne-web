require 'test_helper'
require 'sunspot/rails'
require 'webmock/minitest'

class HooksControllerTest < ActionController::TestCase
  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Will update Order Status to Pickup after Shult Hook Post' do
    assert_equal(statuses(:four).id, common_call('confirmed').status_id, 'Order should be in pickup status (4)')
  end

  test 'Will update Order Status to Delivery after Shult Hook Post' do
    assert_equal(statuses(:five).id, common_call('collected').status_id, 'Order should be in delivery status (5)')
  end

  test 'Will update Order Status to Delivered after Shult Hook Post' do
    assert_equal(statuses(:six).id, common_call('delivered').status_id, 'Order should be in pickup status (6)')
  end

  def common_call(status)
    stub_shutl_token
    order = orders(:order1)
    order.delivery_token = 'abc123'
    order.save
    stub_shutl_booking_status_update(order, status)
    post :updateorder, JSON.parse(shutl_hook_request(order))

    Order.find(order.id)
  end

  def shutl_hook_request(order)
    return '{
        "notification": {
          "type": "booking_update",
          "shutl_booking_reference": "' + order.delivery_token + '",
          "merchant_booking_reference": "MERCHANT_BOOKING_REFERENCE",
          "uri": "https://api.shutl.co.uk/bookings/SHUTL_BOOKING_REF"
        }
      }'
  end

  def stub_shutl_booking_status_update(order, status)
    body =  '{
               "booking":{
                  "reference":"' + order.delivery_token + '",
                  "merchant_booking_reference":"ORDER_35",
                  "third_party_reference":"",
                  "booking_status":"' + status + '",
                  "signed_by":null,
                  "time_zone":"Europe/London",
                  "basket_value":1690,
                  "carrier_name":"ROCS ADL",
                  "vehicle_name":"Bicycle",
                  "courier_name":null,
                  "courier_callsign":null,
                  "courier_numberplate":null,
                  "distance":1.97596,
                  "gift_wrap":false,
                  "card_type":null,
                  "card_last_4_digits":null,
                  "payment_reference":null,
                  "event_codes":[

                  ],
                  "waiting_charges":0,
                  "created_at":"2014-10-31T10:35+00:00",
                  "updated_at":"2014-10-31T10:35+00:00",
                  "total_wait_time":null,
                  "location":null,
                  "estimates":null,
                  "pickup":{
                     "notes":null,
                     "address":{
                        "name":"Amathus City",
                        "company_name":null,
                        "line_1":" 7-19 Leadenhall Market",
                        "line_2":null,
                        "postcode":"EC3V 1LR",
                        "city":"London",
                        "county_or_state":null,
                        "country":"GB"
                     },
                     "contact":{
                        "name":"Amathus City",
                        "phone":"+44 2072830638",
                        "email":"AmathusCity@vynz.co"
                     }
                  },
                  "delivery":{
                     "notes":null,
                     "address":{
                        "name":"Jakub Borys",
                        "company_name":null,
                        "line_1":" 8a Pickfords Wharf, Wharf Road",
                        "line_2":null,
                        "postcode":"N17RJ",
                        "city":"London",
                        "county_or_state":null,
                        "country":"GB"
                     },
                     "contact":{
                        "name":"Jakub Borys",
                        "phone":"+44 7718225201",
                        "email":"jakub.borys@gmail.com"
                     }
                  },
                  "prices":{
                     "customer":584,
                     "merchant":487
                  },
                  "times":{
                     "pickup_start":"2014-10-31T11:00+00:00",
                     "pickup_finish":"2014-10-31T12:00+00:00",
                     "delivery_start":"2014-10-31T12:00+00:00",
                     "delivery_finish":"2014-10-31T13:00+00:00"
                  },
                  "products":[

                  ],
                  "tracking_url":"/orders/track_v2/?orderid=V4AF258\u0026key=fffcf2d163b30877feb7da5da8043cfd"
               }
            }'

    stub_request(:get, "https://sandbox-v2.shutl.co.uk/bookings/abc123").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 493nSJPSh9_jUsjJe3S59FNnAx3-jcKBjBBzCFM_BkF9ePKcmRPqf-XqwZ3GWdBc9M4ZH-mUb0Okn1e_WPKrwg', 'Host'=>'sandbox-v2.shutl.co.uk', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => body, :headers => {})
  end



end