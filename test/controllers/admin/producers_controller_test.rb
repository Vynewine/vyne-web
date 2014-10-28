require 'test_helper'

class Admin::ProducersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include GenericImporter

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    @admin = users(:admin)
    sign_in(:user, @admin)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'Can import producers' do
    inventory_file = fixture_file_upload('files/producers.csv','text/csv')

    post :import , {
        :file => inventory_file
    }

    producers = Producer.find(1)

    assert_redirected_to admin_producers_path
    assert(producers.name == 'Cálem')
  end

  test 'Will error when file not provided' do

    post :import

    assert(flash[:alert] == 'Please specify file to upload.')
  end

  test 'Will error when wrong file uploaded' do
    inventory_file = fixture_file_upload('files/error.png','text/csv')

    post :import , {
        :file => inventory_file
    }

    assert(flash[:alert] == 'File must be .csv format.')

  end
end

