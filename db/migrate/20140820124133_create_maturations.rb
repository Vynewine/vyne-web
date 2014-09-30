class CreateMaturations < ActiveRecord::Migration
  def change
    create_table :maturations do |t|
      t.references :bottling, index: true
      t.integer :period

      t.timestamps
    end
  end
end
