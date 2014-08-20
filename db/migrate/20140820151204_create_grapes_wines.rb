class CreateGrapesWines < ActiveRecord::Migration
  def change
    create_table :grapes_wines do |t|
      t.integer :wine_id
      t.integer :grape_id

      t.timestamps
    end
  end
end
