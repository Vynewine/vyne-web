require 'test_helper'

class CoordinateHelperTest < ActiveSupport::TestCase
  include CoordinateHelper

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    WebMock.allow_net_connect!
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can schedule job' do

  end

end