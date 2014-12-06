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

    #Alex
    #registration_ids= ['APA91bEh_SGnfX-Nv692fpwHW1umzygpuBjCP0Jjz2xumzCKXbn6SuQ99uaSsJUdXTc0vHI2hnmOmpzUMW0ORStm2loWrnSqG-zFmxWawvLsZvduH2aGTu9I-3BpMhgHtOfq8RizSy33RUionEob7S0TJV0untIt_A']
    #Jakub
    #Prod
    #registration_ids= ['APA91bHldaQkrRyE-0HTL9R--iq6kD94SYJcHCS6owxUMPu9meP3MWsB2Cf1U65zbvbZcR7FH3aXNj0s1A2qphnONb1SxB3lII8_Zi2ly3kt_ZHsc9Ot49zh1rxlSVflFequhQnTQjEv-o80JPcvAdpX8gFGpOKScQ']
    #Test
    registration_ids= ['APA91bGCsYTzlEA--0gGrjyk41HqIuxsgzmuEzXd5PtWAusg9u_8jB_Y6MeH0jFVkzteEI2GiGXSY1Ld6tdhFSU8zxp4PE6InSEzea48VEc8HW7DtdRKThw1Zgrf43YKeHS4JE6G0MqGMcB1lhyxNVnJVz-3sJwcvA',
    'APA91bHaaOHWMyBdImHM8tbYjfYRzQIOIq1WDUv0_4y2pnZnQVR7VESkDdi7vxuCD_2jSRZiZn7p8h-H1rD3gcveBY-2zdieNqK4h2OROPr7yLMuE-oLJY5Y4wVouf7tLGKNkjxgAXDJya73iqSAXCIX2fn5a5BC7w']

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