class CreateFoodsWines < ActiveRecord::Migration
  def change
    create_table :foods_wines do |t|
      t.integer :wine_id
      t.integer :food_id

      t.timestamps
    end
  end
end
