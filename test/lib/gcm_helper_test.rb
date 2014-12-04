require 'test_helper'
require 'gcm'

class GoogleGcmHelperTest < ActiveSupport::TestCase
  include GcmHelper


  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    WebMock.allow_net_connect!
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can send notification' do
    gcm = GCM.new('AIzaSyCUuUzZOMAKS1n6kA396bI8FBUWpvdwyWk')

    registration_ids= ['APA91bHrTZEpNICMD3XLiWKpbS6f-whmSfUcETPujP4UJX0Q7YGciFp3rf6XrWCiSbFo3uoV5avYY5JWlGW96aERDrF-uqBAUAspeKEI_QJK6EfgZTBpIFXcBck1p2yUPvS5SmwHwEvVxD_v9KmAKMqzSEyXU5ET_g']

    order1 = Order.new
    order1.save

    options = {
        data: {
            wine_order: {order: order1.id.to_s},
        },
        collapse_key: order1.id.to_s
    }
    response = gcm.send(registration_ids, options)

    puts json: response
  end

  test 'Can send notification for an order' do
    warehouse = warehouses(:one)
    device = devices(:one)
    device.registration_id = 'APA91bHrTZEpNICMD3XLiWKpbS6f-whmSfUcETPujP4UJX0Q7YGciFp3rf6XrWCiSbFo3uoV5avYY5JWlGW96aERDrF-uqBAUAspeKEI_QJK6EfgZTBpIFXcBck1p2yUPvS5SmwHwEvVxD_v9KmAKMqzSEyXU5ET_g'
    device.save
    warehouse.devices << device

    order = orders(:order1)
    order.warehouse = warehouse
    puts json: send_notification(order)

  end

  test 'Can handle error' do
    warehouse = warehouses(:one)
    device_one = devices(:one)
    device_two = devices(:two)
    device_one.registration_id = 'fake'
    device_two.registration_id = 'APA91bHrTZEpNICMD3XLiWKpbS6f-whmSfUcETPujP4UJX0Q7YGciFp3rf6XrWCiSbFo3uoV5avYY5JWlGW96aERDrF-uqBAUAspeKEI_QJK6EfgZTBpIFXcBck1p2yUPvS5SmwHwEvVxD_v9KmAKMqzSEyXU5ET_g'
    device_one.save
    warehouse.devices << [device_one, device_two]

    order = orders(:order1)
    order.warehouse = warehouse
    response = send_notification(order)

    assert(!response[:errors].blank?)

  end
end