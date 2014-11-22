require 'tzinfo'

class Warehouse < ActiveRecord::Base
  acts_as_paranoid

  has_many :agendas, :dependent => :destroy
  belongs_to :address
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

  def is_open
    if self.agendas.blank?
      false
    else
      #TODO: In the future we'll make time zone identifier configurable
      time_zone_identifier = 'Europe/London'
      tz = TZInfo::Timezone.get(time_zone_identifier)
      # current local time
      local_time = tz.utc_to_local(Time.now.getutc)
      # Select agenda for today for a warehouse
      agenda = self.agendas.select { |agenda| agenda.day == local_time.wday }.first
      unless agenda.blank?
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
        (agenda_open < local_time && agenda_close > local_time)
      end
    end
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
  # If you came here to refactor this. Congratulations VYNE made it!
  def self.delivery_area_by_city
    results = ActiveRecord::Base.connection.execute('select ST_Union(w.delivery_area) from warehouses w where w.active = true;')
    #Binary Parser
    parser = ::RGeo::WKRep::WKBParser.new
    parser.parse(results.first['st_union'])
  end
end
