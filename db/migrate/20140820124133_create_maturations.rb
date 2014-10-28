class CreateMaturations < ActiveRecord::Migration
  def change
    create_table :maturations do |t|
      t.references :bottling, index: true
      t.text :description
      t.timestamps
    end
  end
end
