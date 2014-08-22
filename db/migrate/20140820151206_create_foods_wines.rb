class CreateFoodsWines < ActiveRecord::Migration
  def change
    create_join_table :foods, :wines do |t|
      t.index :wine_id
      t.index :food_id
      t.timestamps
    end
  end
end
