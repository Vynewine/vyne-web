class MerchantsController < ApplicationController
  def index

    if params[:lat].blank? || params[:lng].blank?
      render :json => {}
      return
    end


    @warehouses = Warehouse.closest_to(params[:lat], params[:lng])
    warehouses = {warehouses: [], next_opening: {}, delivery_slots: []}
    first_day_delivery_slots = []
    second_day_delivery_slots = []
    warehouse_local_time = nil
    last_midnight = nil
    next_day = nil

    unless @warehouses.blank?
      @warehouses.each do |warehouse|
        warehouses[:warehouses] << {
            id: warehouse.id,
            address: warehouse.address.postcode,
            is_open: warehouse.is_open,
            opening_time: warehouse.today_opening_time,
            closing_time: warehouse.today_closing_time,
            opens_today: warehouse.opens_today,
            title: warehouse.title
        }

        if warehouse_local_time.nil?
          warehouse_local_time = warehouse.local_time
        end

        if last_midnight.nil?
          last_midnight = warehouse_local_time.change(:hour => 0)
        end


        if first_day_delivery_slots.blank?
          6.times do |i|
            if i == 0
              first_day_delivery_slots = warehouse.get_delivery_blocks(warehouse_local_time)
            else
              if first_day_delivery_slots.blank?
                first_day_delivery_slots = warehouse.get_delivery_blocks(last_midnight + (i).day)
              else
                next_day = last_midnight + (i).day
                break
              end
            end
          end
        end

        if second_day_delivery_slots.blank?
          second_day_delivery_slots = warehouse.get_delivery_blocks(next_day)
        end

      end

      warehouses[:next_opening] = next_open_warehouse(@warehouses)

      warehouses[:delivery_slots] = first_day_delivery_slots + second_day_delivery_slots

    end
    render :json => warehouses
  end

  private

  def local_time
    #TODO: In the future we'll make time zone identifier configurable
    time_zone_identifier = 'Europe/London'
    tz = TZInfo::Timezone.get(time_zone_identifier)
    # current local time
    tz.utc_to_local(Time.now.getutc)
  end

  def next_open_warehouse(warehouses)

    today = local_time.wday
    if today == 6 # Saturday
      next_day = 0 # Sunday
    else
      next_day = today + 1
    end

    7.times do

      next_warehouse = warehouses.select { |w| w.next_open_day == next_day }.first
      unless next_warehouse.blank?
        return {
            :day => next_warehouse.next_open_day,
            :week_day => Date::DAYNAMES[next_warehouse.next_open_day],
            :opening_time => next_warehouse.next_open_day_opening_time,
            :closing_time => next_warehouse.next_open_day_closing_time
        }
      end

      next_day += 1
      if next_day == 6
        next_day = 0
      end
    end
  end

  # Only future delivery slots
  # By closest warehouse
  # Array of warehouse Ids and Slots
  # Only slots for next available date
  # Don't mix dates - it can only be less slots left for today or only next day slots.
  def future_delivery_slots(warehouses)
    [
        {day: 'Monday', date: '2015/02/15', from: '13:00', to: '14:00', full: true, warehouse_id: 1},
        {day: 'Monday', date: '2015/02/15', from: '14:00', to: '15:00', full: true, warehouse_id: 1},
        {day: 'Monday', date: '2015/02/15', from: '15:00', to: '16:00', full: false, warehouse_id: 2},
        {day: 'Monday', date: '2015/02/15', from: '16:00', to: '17:00', full: true, warehouse_id: 1}
    ]
  end
end