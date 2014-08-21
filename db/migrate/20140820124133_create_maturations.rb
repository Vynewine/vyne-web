class CreateMaturations < ActiveRecord::Migration
  def change
    create_table :maturations do |t|
      t.integer :bottling_id
      t.integer :period

      t.timestamps
    end
  end
end
