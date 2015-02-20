require 'tzinfo'

class Warehouse < ActiveRecord::Base
  acts_as_paranoid

  has_many :agendas, :dependent => :destroy
  belongs_to :address
  has_and_belongs_to_many :users, :join_table => :users_warehouses
  has_many :devices
  validates :title, :email, :phone, :address, :presence => true
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :agendas, :reject_if => :all_blank, :allow_destroy => true

  def agendas_attributes=(agendas_attributes)
    agendas_attributes.values.each do |agenda_attributes|
      agenda_to_update = Agenda.find_by_id(agenda_attributes[:id]) || self.agendas.build
      if self.id || self.title && self.email && self.address
        u = agenda_to_update.update_attributes(agenda_attributes)
      end
      # puts u
    end
  end

  def short_name
    "#{title} (active: #{active})"
  end

  def shutl_id
    "vyne_store_#{id}"
  end

  def is_open_for_live_delivery
    if self.agendas.blank?
      false
    else
      agenda = self.agendas.select { |agenda| agenda.day == local_time.wday }.first
      if agenda.blank? || !agenda.opens_today || agenda.live_delivery_from.blank? || agenda.live_delivery_to.blank?
        false
      else
        agenda_open = DateTime.new(local_time.year,
                                   local_time.month,
                                   local_time.day,
                                   agenda.live_delivery_from.hour,
                                   agenda.live_delivery_from.min,
                                   agenda.live_delivery_from.sec
        )

        agenda_close = DateTime.new(local_time.year,
                                    local_time.month,
                                    local_time.day,
                                    agenda.live_delivery_to.hour,
                                    agenda.live_delivery_to.min,
                                    agenda.live_delivery_to.sec
        )

        (agenda_open <= local_time && agenda_close >= local_time)
      end
    end
  end

  def is_open
    if self.agendas.blank?
      false
    else
      # Select agenda for today for a warehouse
      agenda = self.agendas.select { |agenda| agenda.day == local_time.wday }.first
      if agenda.blank?
        false
      elsif !agenda.opens_today
        false
      else

        # get date time for agenda
        # trick is to use current local date and agenda's time
        agenda_open_time = Time.parse(agenda.opening_time)
        agenda_open = DateTime.new(local_time.year,
                                   local_time.month,
                                   local_time.day,
                                   agenda_open_time.hour,
                                   agenda_open_time.min,
                                   agenda_open_time.sec
        )

        agenda_close_time = Time.parse(agenda.closing_time)
        agenda_close = DateTime.new(local_time.year,
                                    local_time.month,
                                    local_time.day,
                                    agenda_close_time.hour,
                                    agenda_close_time.min,
                                    agenda_close_time.sec
        )

        # compare agenda open/close to local time
        (agenda_open <= local_time && agenda_close >= local_time)
      end
    end
  end

  def is_open_on_day (day)
    agenda = self.agendas.select { |agenda| agenda.day == day.wday }.first
    if agenda.blank?
      false
    else
      agenda.opens_today
    end
  end

  def opening_on_day (day)
    agenda = self.agendas.select { |agenda| agenda.day == day.wday }.first
    if agenda.blank?
      false
    else
      agenda.opening_time
    end
  end

  def closing_on_day (day)
    agenda = self.agendas.select { |agenda| agenda.day == day.wday }.first
    if agenda.blank?
      false
    else
      agenda.closing_time
    end
  end

  def today_opening_time
    # Select agenda for today for a warehouse
    agenda = self.agendas.select { |agenda| agenda.day == local_time.wday }.first
    unless agenda.blank? || agenda.live_delivery_from.blank?
      agenda.live_delivery_from.strftime('%H:%M')
    end
  end

  def today_closing_time
    # Select agenda for today for a warehouse
    agenda = self.agendas.select { |agenda| agenda.day == local_time.wday }.first
    unless agenda.blank? || agenda.live_delivery_to.blank?
      agenda.live_delivery_to.strftime('%H:%M')
    end
  end

  def opens_today
    agenda = self.agendas.select { |agenda| agenda.day == local_time.wday }.first
    if agenda.blank? || today_closing_time.blank?
      false
    else
      if agenda.opens_today
        closing_time = Time.parse(today_closing_time)
        if local_time < closing_time
          true
        else
          false
        end
      else
        false
      end
    end
  end

  def local_time
    #TODO: In the future we'll make time zone identifier configurable
    time_zone_identifier = 'Europe/London'
    tz = TZInfo::Timezone.get(time_zone_identifier)
    # current local time
    tz.utc_to_local(Time.now.getutc)
  end

  def area=(area)

    if area.blank?
      coordinates = '[[]]'
    else
      coordinates = area
    end

    area = {
        :type => 'Polygon',
        :coordinates => JSON.parse(coordinates)
    }

    self.delivery_area = RGeo::GeoJSON.decode(area.to_json, :json_parser => :json)
  end

  def area
    area = '[['
    unless delivery_area.blank?
      delivery_area.exterior_ring.points.each_with_index do |point, index|

        area += '[' + point.x.to_s + ', ' + point.y.to_s + ']'

        if index < (delivery_area.exterior_ring.points.length - 1)
          area += ', '
        end
      end
    end
    area += ']]'
    area
  end

  #TODO: Actually take city as a parameter ;)
  # If you came here to refactor this, congratulations VYNE made it!
  def self.delivery_area_by_city
    results = ActiveRecord::Base.connection.execute('select ST_Union(w.delivery_area) from warehouses w where w.active = true;')
    #Binary Parser
    parser = ::RGeo::WKRep::WKBParser.new
    unless results.first.blank? || results.first['st_union'].blank?
      parser.parse(results.first['st_union'])
    end
  end

  def self.delivery_areas

    delivery_areas = delivery_area_by_city

    areas = ''

    unless delivery_areas.blank?
      if delivery_areas.is_a?(RGeo::Cartesian::MultiPolygonImpl)
        delivery_areas.each_with_index do |polygon, polygon_index|
          polygon.exterior_ring.points.each_with_index do |point, index|
            if index == 0
              areas += '['
            end
            areas += '[' + point.y.to_s + ', ' + point.x.to_s + ']'
            if index < (polygon.exterior_ring.points.length - 1)
              areas += ','
            else
              areas += ']'
            end
          end
          if polygon_index < (delivery_areas.count - 1)
            areas += ','
          end
        end
      elsif delivery_areas.is_a?(RGeo::Cartesian::PolygonImpl)
        delivery_areas.exterior_ring.points.each_with_index do |point, index|
          if index == 0
            areas += '['
          end
          areas += '[' + point.y.to_s + ', ' + point.x.to_s + ']'
          if index < (delivery_areas.exterior_ring.points.count - 1)
            areas += ','
          else
            areas += ']'
          end
        end
      end
    end

    areas
  end

  # Find closest warehouse delivering to lat/lng area
  def self.delivering_to(lat, lng)
    point = "'POINT(#{lng} #{lat})'"
    warehouses = Warehouse.find_by_sql("select w.* from warehouses w
                          join addresses a on w.address_id = a.id
                          where ST_Contains(w.delivery_area, #{point})
                          and w.active = true
                          order by ST_Distance (#{point}, a.coordinates) asc")
    warehouses
  end

  def distance_from(lat, lng)
    unless address.blank? || address.coordinates.blank?
      factory = RGeo::Geographic.spherical_factory
      point = factory.point(lng, lat)
      point.distance(address.coordinates)
    end
  end

  def get_delivery_blocks(time)

    agenda = self.agendas.select { |agenda| agenda.day == time.wday }.first
    unless agenda.blank?
      blocks = agenda.available_delivery_blocks(time)

      unless blocks.blank?
        blocks.map do |block|
          {
              :from => block[:from],
              :to => block[:to],
              :date => time.strftime('%F'),
              :day => time.wday == local_time.wday ? 'Today' : Date::DAYNAMES[time.wday],
              :warehouse_id => self.id,
              :title => self.title,
              :type => block[:type]
          }
        end
      end
    end
  end

end
