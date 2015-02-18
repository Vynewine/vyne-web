require 'test_helper'
require 'tzinfo'
require 'mocha/test_unit'

class AgendaTest < ActiveSupport::TestCase

  setup do
    @warehouse = Warehouse.create!({
                                       :title => 'Warehouse 1',
                                       :email => 'waregouse1@vyne.london',
                                       :phone => '07718225201',
                                       :address => addresses(:one)
                                   })


    Agenda.create!({
                       :day => 0, #Sunday
                       :opening => 1200,
                       :closing => 1700,
                       :warehouse => @warehouse
                   })

    Agenda.create!({
                       :day => 1, #Monday
                       :opening => 1100,
                       :closing => 2100,
                       :warehouse => @warehouse
                   })
  end

  test 'Warehouse is open' do
    @time_now = Time.parse('1996/01/01 12:00') #Monday
    Time.stubs(:now).returns(@time_now)
    assert(@warehouse.is_open, 'Warehouse should be opened')

  end

  test 'Warehouse is closed' do
    @time_now = Time.parse('1996/01/07 10:00') #Sunday
    Time.stubs(:now).returns(@time_now)
    assert_equal(false, @warehouse.is_open, 'Warehouse should be closed')
  end

  def uneven_agenda
    Agenda.create!({
                       :day => 1,
                       :delivery_slots_from => '14:30',
                       :delivery_slots_to => '17:10',
                       :live_delivery_from => '17:10',
                       :live_delivery_to => '20:30'
                   })
  end


  test 'Will round up delivery slots time to nearest hour' do
    agenda = uneven_agenda
    assert_equal('15:00', agenda.block_delivery_start_time.strftime('%H:%M'))
    assert_equal('17:00', agenda.live_delivery_block_start_time.strftime('%H:%M'))

  end

  test 'Will round down delivery slots to nearest hour' do
    agenda = uneven_agenda
    assert_equal('17:00', agenda.block_delivery_end_time.strftime('%H:%M'))
    assert_equal('20:00', agenda.live_delivery_block_end_time.strftime('%H:%M'))
  end

  def even_agenda
    Agenda.create!({
                       :day => 1,
                       :delivery_slots_from => '14:00',
                       :delivery_slots_to => '17:00',
                       :live_delivery_from => '17:00',
                       :live_delivery_to => '20:00'
                   })
  end

  test 'Will not round up delivery slots time to nearest hour' do
    agenda = even_agenda
    assert_equal('14:00', agenda.block_delivery_start_time.strftime('%H:%M'))
    assert_equal('17:00', agenda.live_delivery_block_start_time.strftime('%H:%M'))

  end

  test 'Will not round down delivery slots to nearest hour' do
    agenda = even_agenda
    assert_equal('17:00', agenda.block_delivery_end_time.strftime('%H:%M'))
    assert_equal('20:00', agenda.live_delivery_block_end_time.strftime('%H:%M'))
  end

  test 'Can get delivery slots since 9am' do
    @time_now = Time.parse('1996/01/01 9:00') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 1,1,1,1,1,1)
  end

  test 'Can get delivery slots since 12pm' do
    @time_now = Time.parse('1996/01/01 12:00') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 1,1,1,1,1,1)
  end

  test 'Can get delivery slots since 1pm' do
    @time_now = Time.parse('1996/01/01 13:00') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 0,1,1,1,1,1)
  end

  test 'Can get delivery slots since 1:01pm' do
    @time_now = Time.parse('1996/01/01 13:01') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 0,0,1,1,1,1)
  end

  test 'Can get delivery slots since 3pm' do
    @time_now = Time.parse('1996/01/01 15:00') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 0,0,0,1,1,1)
  end

  test 'Can get delivery slots since 3:01pm' do
    @time_now = Time.parse('1996/01/01 15:01') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 0,0,0,1,1,1)
  end

  test 'Can get delivery slots since 4pm' do
    @time_now = Time.parse('1996/01/01 16:00') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 0,0,0,1,1,1)
  end

  test 'Can get delivery slots since 4:01pm' do
    @time_now = Time.parse('1996/01/01 16:01') #Monday
    agenda = agendas(:warehouse_two_monday)
    available_slots = agenda.available_delivery_blocks(@time_now)
    assert_slots(available_slots, 0,0,0,0,1,1)
  end

  def find_slot(slots, from, to)
    slots.select { |slot| slot[:from] == from && slot[:to] == to }.count
  end

  def assert_slots(slots, first_count, second_count, third_count, fourth_count, fifth_count, sixth_count)
    assert_equal(first_count, find_slot(slots, '14:00', '15:00'))
    assert_equal(second_count, find_slot(slots, '15:00', '16:00'))
    assert_equal(third_count, find_slot(slots, '16:00', '17:00'))
    assert_equal(fourth_count, find_slot(slots, '17:00', '18:00'))
    assert_equal(fifth_count, find_slot(slots, '18:00', '19:00'))
    assert_equal(sixth_count, find_slot(slots, '19:00', '20:00'))
  end
end