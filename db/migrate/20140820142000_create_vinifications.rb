class CreateVinifications < ActiveRecord::Migration
  def change
    create_table :vinifications do |t|
      t.text :description
      t.string :name
      t.timestamps
    end
  end
end