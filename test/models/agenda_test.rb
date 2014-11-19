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

end