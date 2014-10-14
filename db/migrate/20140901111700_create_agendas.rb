class CreateAgendas < ActiveRecord::Migration
  def change
    create_table :agendas do |t|
      t.references :warehouse, index: true
      t.integer :day
      t.integer :opening
      t.integer :closing

      t.timestamps
    end
    add_index :agendas, :day
    add_index :agendas, :opening
    add_index :agendas, :closing
  end
end
