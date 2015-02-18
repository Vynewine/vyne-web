class AddDeliverySlotsToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :delivery_slots_from, :time
    add_column :agendas, :delivery_slots_to, :time
    add_column :agendas, :live_delivery_from, :time
    add_column :agendas, :live_delivery_to, :time
  end
end
