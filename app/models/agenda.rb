class Agenda < ActiveRecord::Base
  belongs_to :warehouse

  validates_uniqueness_of :day, :scope => [:warehouse]

  after_create :def_after_create

  def def_after_create
    if warehouse_id.nil?
      self.destroy
    end
  end

  def day_name
    Date::DAYNAMES[day]
  end

  def opening_time
    unless live_delivery_from.blank?
      live_delivery_from.strftime('%H:%M')
    end
  end

  def closing_time
    unless live_delivery_to.blank?
      live_delivery_to.strftime('%H:%M')
    end
  end

  def shutl_time(a)
    b = a/100
    c = a-b*100
    b*60+c
  end

  def shutl_opening
    shutl_time(opening)
  end

  def shutl_closing
    shutl_time(closing)
  end

  # Sometimes slots can be set not to the full hours
  # especially closing times
  # We need to round up opening and rond down closing times to the nearest hour

  def block_delivery_start_time
    unless delivery_slots_from.blank?
      delivery_slots_from.round_up(60.minutes)
    end
  end

  def block_delivery_end_time
    unless delivery_slots_to.blank?
      delivery_slots_to.floor(60.minutes)
    end
  end

  def live_delivery_block_start_time
    unless live_delivery_from.blank?
      live_delivery_from.round_up(60.minutes)
    end
  end

  def live_delivery_block_end_time
    unless live_delivery_to.blank?
      live_delivery_to.floor(60.minutes)
    end
  end

  # Block slots are slots that can only be booked in advance and don't follow love delivery

  def block_slots
    slots = []

    unless block_delivery_end_time.blank? || block_delivery_start_time.blank?

      available_hours = block_delivery_end_time - block_delivery_start_time

      number_of_slots = available_hours / 60.minutes

      number_of_slots.to_i.times do |i|
        slots << {
            from: block_delivery_start_time + i.hours,
            to: block_delivery_start_time + (i + 1).hours,
            type: :daytime
        }
      end
    end

    slots
  end

  # Live slots are slots that can be book in advance but we can also deliver live.

  def live_slots
    slots = []

    unless live_delivery_block_end_time.blank? || live_delivery_block_start_time.blank?
      available_hours = live_delivery_block_end_time - live_delivery_block_start_time

      number_of_slots = available_hours / 60.minutes

      number_of_slots.to_i.times do |i|
        slots << {
            from: live_delivery_block_start_time + i.hours,
            to: live_delivery_block_start_time + (i + 1).hours,
            type: :live
        }
      end
    end

    slots
  end

  # Based on time provided we have to determine which slots are still available for given day
  # Block slots can only be booked up to 1 hours before
  # Live slots can only be booked up to the minute before

  def available_delivery_blocks(time)

    unless opens_today
      return []
    end

    # Reset date to compare with Postgres Time
    time = time.change(:month => 1, :day => 1, :year => 2000)

    lead_time_for_block_time_slots = 1.hour

    all_slots = block_slots.select { |slot| slot[:from] >= (time + lead_time_for_block_time_slots) } +
        live_slots.select { |slot| slot[:from] >= (time) }

    all_slots.map do |slot|
      {
          :from => slot[:from].strftime('%H:%M'),
          :to => slot[:to].strftime('%H:%M'),
          :type => slot[:type]
      }
    end
  end
end

class Time
  def round_up(seconds = 60)
    Time.at((self.to_f / seconds).round * seconds)
  end

  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end
end