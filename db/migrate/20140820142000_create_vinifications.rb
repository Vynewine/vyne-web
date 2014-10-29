class CreateVinifications < ActiveRecord::Migration
  def change
    create_table :vinifications do |t|
      t.text :method
      t.string :name
      t.timestamps
    end
  end
end