require 'test_helper'

class MerchantsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do

  end


  test 'Should return two nearby warehouses' do

    address = addresses(:five)
    get :index, { lat: address.latitude, lng: address.longitude }
    assert_equal(2, JSON.parse(@response.body)['warehouses'].count)

    #puts JSON.pretty_generate(JSON.parse(@response.body))
  end

  test 'Should return one nearby warehouse' do
    address = addresses(:four)
    get :index, { lat: address.latitude, lng: address.longitude }
    assert_equal(1, JSON.parse(@response.body)['warehouses'].count)
  end

  test 'Should return slots for next two days from warehouse two' do
    time_now = Time.parse('1996/01/01 09:00') # Monday
    address = addresses(:five)
    Time.stubs(:now).returns(time_now)
    get :index, { lat: address.latitude, lng: address.longitude }
    warehouse_info = JSON.parse(@response.body)

    assert_slots(warehouse_info['delivery_slots'], '1996-01-01', 1,1,1,1,1,1)
    assert_slots(warehouse_info['delivery_slots'], '1996-01-02', 1,1,1,1,1,0)

  end

  test 'Should return slots for next two days from warehouse two and three' do
    time_now = Time.parse('1996/01/02 09:00') # Tuesday
    address = addresses(:five)
    Time.stubs(:now).returns(time_now)
    get :index, { lat: address.latitude, lng: address.longitude }
    warehouse_info = JSON.parse(@response.body)

    puts warehouse_info['delivery_slots']

    assert_slots(warehouse_info['delivery_slots'], '1996-01-02', 1,1,1,1,1,0)
    assert_slots(warehouse_info['delivery_slots'], '1996-01-03', 0,1,1,1,0,0)
  end

  def find_slot(slots, from, to, date)
    slots.select { |slot| slot['from'] == from && slot['to'] == to && slot['date'] == date }.count
  end

  def assert_slots(slots, date, first_count, second_count, third_count, fourth_count, fifth_count, sixth_count)
    assert_equal(first_count, find_slot(slots, '14:00', '15:00', date))
    assert_equal(second_count, find_slot(slots, '15:00', '16:00', date))
    assert_equal(third_count, find_slot(slots, '16:00', '17:00', date))
    assert_equal(fourth_count, find_slot(slots, '17:00', '18:00', date))
    assert_equal(fifth_count, find_slot(slots, '18:00', '19:00', date))
    assert_equal(sixth_count, find_slot(slots, '19:00', '20:00', date))
  end

end