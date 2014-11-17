require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  test 'Can save address coordinates' do
    Address.create!(
        {
            :company_name => 'Company 1',
            :line_1 => 'Street 1',
            :line_2 => 'Street 2',
            :postcode => 'N1 7RL',
            :coordinates => 'POINT(-122 47)'
        }
    )

    address = Address.where(postcode: 'N1 7RL').first
    assert_equal(-122, address.coordinates.x)
    assert_equal(47, address.coordinates.y)
  end

  test 'Can set address coordinates' do
    address = Address.new(
        {
            :company_name => 'Company 1',
            :line_1 => 'Street 1',
            :line_2 => 'Street 2',
            :postcode => 'N1 7RL'
        }
    )

    address.longitude = -0.108106
    address.latitude = 51.520068

    address.save

    address = Address.where(postcode: 'N1 7RL').first
    assert_equal(-0.108106, address.longitude)
    assert_equal(51.520068, address.latitude)
  end

  test 'Will fail setting coordinates' do
    address = Address.new(
        {
            :company_name => 'Company 1',
            :line_1 => 'Street 1',
            :line_2 => 'Street 2',
            :postcode => 'N1 7RL'
        }
    )

    address.longitude = -0.108106
    address.latitude = 0

    assert_equal(false, address.valid?)
    assert_equal(false, address.save)
    assert_equal('Coordinates longitude and latitude are required', address.errors.full_messages.join(''))

    address = Address.where(postcode: 'N1 7RL').first
    assert_equal(nil, address)
  end

  test 'Will fail all coordinates conditions' do
    address = Address.new({})
    address.longitude = -0.108106
    assert_equal(false, address.valid?)

    address = Address.new({})
    address.latitude = -0.108106
    assert_equal(false, address.valid?)

    address = Address.new({})
    address.longitude = -0.108106
    address.latitude = 0
    assert_equal(false, address.valid?)

    address = Address.new({})
    address.longitude = 0
    address.latitude = -0.108106
    assert_equal(false, address.valid?)
  end

  test 'Coordinates default to 0.0' do
    Address.create!(
        {
            :company_name => 'Company 1',
            :line_1 => 'Street 1',
            :line_2 => 'Street 2',
            :postcode => 'N1 7RL'
        }
    )

    address = Address.where(postcode: 'N1 7RL').first
    puts json: address.coordinates
    # assert_equal(0, address.latitude)
    # assert_equal(0, address.longitude)
  end
end