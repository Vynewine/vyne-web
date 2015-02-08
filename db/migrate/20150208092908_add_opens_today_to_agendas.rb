class AddOpensTodayToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :opens_today, :boolean, :default => true
  end
end
