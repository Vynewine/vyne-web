class CreateCompositions < ActiveRecord::Migration
  def change
    create_table :compositions do |t|
      t.references :grape, index: true
      t.references :wine, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
