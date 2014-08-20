class CreateWineMaturations < ActiveRecord::Migration
  def change
    create_table :wine_maturations do |t|
      t.integer :maturation_type_id
      t.integer :period

      t.timestamps
    end
  end
end
