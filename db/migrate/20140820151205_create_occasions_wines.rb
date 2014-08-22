class CreateOccasionsWines < ActiveRecord::Migration
  def change
    create_join_table :occasions, :wines do |t|
      t.index :wine_id
      t.index :occasion_id
      t.timestamps
    end
  end
end
