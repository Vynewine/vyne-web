class Warehouse < ActiveRecord::Base
  acts_as_paranoid

  has_many :agendas, :dependent => :destroy
  belongs_to :address
  validates :title, :email, :phone, :address, :presence => true
  validates_presence_of :shutl, :message => "Shutl server responded with an error. Please try again."
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :agendas, :reject_if => :all_blank, :allow_destroy => true
  after_create :set_default_agenda

  def set_default_agenda
    if agendas.count == 0
      for i in 0..6 do
        Agenda.create(
          :warehouse_id => self.id,
                   :day => i,
               :opening =>  900,
               :closing => 1800
        )
      end
    end     
  end
  
  def agendas_attributes=(agendas_attributes)
    agendas_attributes.values.each do |agenda_attributes|
      agenda_to_update = Agenda.find_by_id(agenda_attributes[:id]) || self.agendas.build
      if self.id || self.title && self.email && self.address
        u = agenda_to_update.update_attributes(agenda_attributes)
      end
      # puts u
    end
  end

  def shutl_id
    n = title.gsub(/\s+/, "").upcase
    d = created_at || Time.new
    t = d.to_time.strftime("%H%M_%d%m%y")
    "Warehouse_#{n}_#{t}"
  end

end
