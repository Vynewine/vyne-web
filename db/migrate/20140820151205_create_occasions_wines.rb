class CreateOccasionsWines < ActiveRecord::Migration
  def change
    create_table :occasions_wines do |t|
      t.integer :wine_id
      t.integer :occasion_id

      t.timestamps
    end
  end
end
