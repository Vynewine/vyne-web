require 'test_helper'
require 'gcm'

class GoogleGcmlHelperTest < ActiveSupport::TestCase
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

    options = {
        data: {
            wine_order: {order: '123', wines: {wine_01: 'red', wine_02: 'white'}},
            collapse_key: 'updated_score'}
    }
    response = gcm.send(registration_ids, options)
    puts json: response
  end
end