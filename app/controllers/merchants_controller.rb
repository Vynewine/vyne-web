class MerchantsController < ApplicationController

  # TODO - This is madness
  # Need to move it to API namespace
  # Need to separate this to multiple calls based on the resources: Warehouses, Promotions
  # Ideally batch REST calls.
  def index

    if params[:lat].blank? || params[:lng].blank?
      render :json => {}
      return
    end

    unless params[:postcode].blank?
      cookies[:postcode] = params[:postcode]
    end

    warehouse_info = {
        today_warehouse: {},
        next_open_warehouse: {},
        delivery_slots: [],
        daytime_slots_available: false,
        promotion: {}
    }

    warehouse_info[:promotion] = get_promotion_info

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
          title: closest_warehouse.title,
          coming_soon: closest_warehouse.active_from.blank? ? false : local_time < closest_warehouse.active_from,
          active_from: closest_warehouse.active_from
      }

      warehouse_info[:next_open_warehouse] = next_open_warehouse(warehouses)


      if !closest_warehouse.active_from.blank? && local_time < closest_warehouse.active_from
        warehouse_info[:delivery_slots] = get_delivery_slots(warehouses, closest_warehouse.active_from)
      else
        warehouse_info[:delivery_slots] = get_delivery_slots(warehouses)
      end


      daytime_slots_available = false

      unless warehouse_info[:delivery_slots].blank?
        daytime_slots_available = warehouse_info[:delivery_slots].select { |slot| slot[:type] == :daytime }.count > 0
      end

      warehouse_info[:daytime_slots_available] = daytime_slots_available

      logger.info warehouse_info

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

      last_midnight = nil

      if last_midnight.nil?
        last_midnight = local_time.change(:hour => 0)
      end

      7.times do |i|
        tomorrow = last_midnight + (i + 1).day
        next_warehouse = warehouses.select { |w| w.is_open_on_day(tomorrow) }.first
        unless next_warehouse.blank?

          return {
              :day => tomorrow.wday,
              :week_day => Date::DAYNAMES[tomorrow.wday],
              :opening_time => next_warehouse.opening_on_day(tomorrow),
              :closing_time => next_warehouse.closing_on_day(tomorrow),
              :warehouse => next_warehouse.title
          }
        end
      end
    end
    nil
  end

  def get_delivery_slots(warehouses, active_from = nil)

    first_day_delivery_slots = []
    second_day_delivery_slots = []
    if active_from.blank?
      warehouse_local_time = local_time
    else
      warehouse_local_time = active_from
    end

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

  def get_promotion_info

    promotion = nil
    promotion_code = ''
    promotion_category = ''

    if user_signed_in?

      user_promotion = UserPromotion.order(created_at: :asc).find_by(
          :user => current_user,
          :can_be_redeemed => true,
          :redeemed => false
      )

      unless user_promotion.blank?
        promotion = user_promotion.promotion_code.promotion
        promotion_code = user_promotion.promotion_code.code
      end

    else
      unless cookies[:promo_code].blank?
        promo_code = PromotionCode.find_by(code: cookies[:promo_code])
        unless promo_code.blank?
          promotion = promo_code.promotion
          promotion_code = promo_code.code
        end
      end
    end

    unless promotion.blank?
      return {
          :title => promotion.title,
          :code => promotion_code
      }
    end
  end
end