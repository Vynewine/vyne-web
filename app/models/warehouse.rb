class Warehouse < ActiveRecord::Base
  acts_as_paranoid

  has_many :agendas, :dependent => :destroy
  belongs_to :address
  validates :title, :email, :phone, :address, :presence => true
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

  def short_name
      "#{title} (active: #{active})"
  end

  def shutl_id
    "vyne_store_#{id}"
  end
end
