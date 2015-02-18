require 'test_helper'

class MerchantsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'Should return warehouse opening today' do

    time_now = Time.parse('1996/01/03 09:00') # Wednesday
    Time.stubs(:now).returns(time_now)

    address = addresses(:five)
    get :index, {lat: address.latitude, lng: address.longitude}

    response = JSON.parse(@response.body)

    today_warehouse = response['today_warehouse']

    assert(today_warehouse['id'].blank? === false)
    assert(today_warehouse['is_open'] === false)
    assert(today_warehouse['opens_today'])
    assert_equal('W1F 8PZ', today_warehouse['address'])
    assert_equal('17:00', today_warehouse['opening_time'])
    assert_equal('18:00', today_warehouse['closing_time'])

    delivery_slots = response['delivery_slots']
    assert_equal(delivery_slots[0]['warehouse_id'], today_warehouse['id'])
    assert_equal(3, delivery_slots.count)

    assert(JSON.parse(@response.body)['next_open_warehouse']['closing_time'].blank? === false)


  end

  test 'Should return warehouse closed today and opening on Monday' do

    time_now = Time.parse('1996/01/04 09:00') # Thursday
    Time.stubs(:now).returns(time_now)

    address = addresses(:five)
    get :index, {lat: address.latitude, lng: address.longitude}

    #puts JSON.pretty_generate(JSON.parse(@response.body))

    response = JSON.parse(@response.body)

    today_warehouse = response['today_warehouse']

    assert(today_warehouse['id'].blank? === false)
    assert(today_warehouse['is_open'] === false)
    assert(today_warehouse['opens_today'] === false)
    assert_equal('W1F 8BH', today_warehouse['address'])
    assert_equal(nil, today_warehouse['opening_time'])
    assert_equal(nil, today_warehouse['closing_time'])

    delivery_slots = response['delivery_slots']
    assert_equal(delivery_slots[0]['warehouse_id'], today_warehouse['id'])
    assert_equal(11, delivery_slots.count)

  end

  test 'Should return one nearby warehouse' do
    address = addresses(:four)
    get :index, {lat: address.latitude, lng: address.longitude}
    assert(JSON.parse(@response.body)['today_warehouse']['id'].blank? === false)
  end

  test 'Should return slots for next two days from warehouse two' do
    time_now = Time.parse('1996/01/01 09:00') # Monday
    address = addresses(:five)
    Time.stubs(:now).returns(time_now)
    get :index, {lat: address.latitude, lng: address.longitude}
    warehouse_info = JSON.parse(@response.body)

    assert_slots(warehouse_info['delivery_slots'], '1996-01-01', 1, 1, 1, 1, 1, 1)
    assert_slots(warehouse_info['delivery_slots'], '1996-01-02', 1, 1, 1, 1, 1, 0)

  end

  test 'Should return slots for next two days from warehouse two and three' do
    time_now = Time.parse('1996/01/02 09:00') # Tuesday
    address = addresses(:five)
    Time.stubs(:now).returns(time_now)
    get :index, {lat: address.latitude, lng: address.longitude}
    warehouse_info = JSON.parse(@response.body)

    assert_slots(warehouse_info['delivery_slots'], '1996-01-02', 1, 1, 1, 1, 1, 0)
    assert_slots(warehouse_info['delivery_slots'], '1996-01-03', 0, 1, 1, 1, 0, 0)
  end

  test 'Should return slots for next two days from warehouse three' do
    time_now = Time.parse('1996/01/04 09:00') # Thursday
    address = addresses(:six)
    Time.stubs(:now).returns(time_now)
    get :index, {lat: address.latitude, lng: address.longitude}
    warehouse_info = JSON.parse(@response.body)

    assert_slots(warehouse_info['delivery_slots'], '1996-01-09', 1, 1, 1, 1, 1, 1)
    assert_slots(warehouse_info['delivery_slots'], '1996-01-10', 0, 1, 1, 1, 0, 0)
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