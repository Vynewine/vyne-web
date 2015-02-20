class MerchantsController < ApplicationController
  def index

    if params[:lat].blank? || params[:lng].blank?
      render :json => {}
      return
    end

    unless params[:postcode].blank?
      cookies[:postcode] = params[:postcode]
    end


    warehouse_info = {today_warehouse: {}, next_open_warehouse: {}, delivery_slots: [], daytime_slots_available: false}

    warehouses = Warehouse.delivering_to(params[:lat], params[:lng])

    unless warehouses.blank?

      closest_warehouse = select_closest_warehouse(warehouses, params[:lat], params[:lng])

      warehouse_info[:today_warehouse] = {
          id: closest_warehouse.id,
          address: closest_warehouse.address.postcode,
          is_open: closest_warehouse.is_open_for_live_delivery,
          opening_time: closest_warehouse.today_opening_time,
          closing_time: closest_warehouse.today_closing_time,
          opens_today: closest_warehouse.opens_today,
          title: closest_warehouse.title
      }

      warehouse_info[:next_open_warehouse] = next_open_warehouse(warehouses)

      warehouse_info[:delivery_slots] = get_delivery_slots(warehouses)

      warehouse_info[:daytime_slots_available] = warehouse_info[:delivery_slots].blank? ? false : warehouse_info[:delivery_slots].select { |slot| slot[:type] == :daytime }.count > 0

    end
    render :json => warehouse_info
  end

  private

  def select_closest_warehouse(warehouses, lat, lng)
    final_warehouse = nil
    distance = nil
    is_open = false
    opens_today = false
    warehouses.each do |warehouse|
      current_distance = warehouse.distance_from(lat, lng)
      if final_warehouse.blank?
        final_warehouse = warehouse
        distance = current_distance
        is_open = warehouse.is_open_for_live_delivery
        opens_today = warehouse.opens_today
      else
        if distance > current_distance ||
            (!is_open && warehouse.is_open_for_live_delivery) ||
            (!opens_today && warehouse.opens_today)

          if is_open && !warehouse.is_open_for_live_delivery
            break
          end

          if opens_today && !warehouse.opens_today
            break
          end

          final_warehouse = warehouse
          distance = current_distance
        end
      end
    end
    final_warehouse
  end

  def next_open_warehouse(warehouses)

    unless warehouses.blank?
      today = warehouses[0].local_time.wday
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

  end

  def get_delivery_slots(warehouses)

    first_day_delivery_slots = []
    second_day_delivery_slots = []
    warehouse_local_time = local_time
    last_midnight = nil

    if last_midnight.nil?
      last_midnight = warehouse_local_time.change(:hour => 0)
    end

    7.times do |i|
      if i == 0
        first_day_delivery_slots = get_warehouse_and_slots(warehouses, warehouse_local_time)
      else
        if first_day_delivery_slots.blank?
          first_day_delivery_slots = get_warehouse_and_slots(warehouses, (last_midnight + (i).day))
        elsif second_day_delivery_slots.blank?
          second_day_delivery_slots = get_warehouse_and_slots(warehouses, (last_midnight + (i).day))
          unless second_day_delivery_slots.blank?
            break
          end
        end
      end
    end

    first_slots = []
    second_slots = []
    unless first_day_delivery_slots.blank?
      first_slots = first_day_delivery_slots
    end

    unless second_day_delivery_slots.blank?
      second_slots = second_day_delivery_slots
    end

    first_slots + second_slots
  end

  def get_warehouse_and_slots(warehouses, day)
    open_warehouse = nil
    warehouses.each do |warehouse|
      if warehouse.is_open_on_day(day) && open_warehouse.blank?
        open_warehouse = warehouse
      end
    end
    if open_warehouse.blank?
      nil
    else
      open_warehouse.get_delivery_blocks(day)
    end
  end

  def get_open_warehouse_for_day(warehouses, day)
    open_warehouse = nil
    warehouses.each do |warehouse|
      if warehouse.is_open_on_day(day) && open_warehouse.blank?
        open_warehouse = warehouse
      end
    end
    open_warehouse
  end

  def local_time
    #TODO: In the future we'll make time zone identifier configurable
    time_zone_identifier = 'Europe/London'
    tz = TZInfo::Timezone.get(time_zone_identifier)
    # current local time
    tz.utc_to_local(Time.now.getutc)
  end

end