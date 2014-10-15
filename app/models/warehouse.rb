class Warehouse < ActiveRecord::Base
  has_many :agendas
  belongs_to :address
  validates :address, :presence => true
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :agendas, :reject_if => :all_blank, :allow_destroy => true
  after_create :set_default_agenda
  
  def set_default_agenda
    if agendas.count == 0
      for i in 1..7 do
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
      u = agenda_to_update.update_attributes(agenda_attributes)
    end
  end


end
