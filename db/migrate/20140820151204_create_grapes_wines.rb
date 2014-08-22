class CreateGrapesWines < ActiveRecord::Migration
  def change
    create_join_table :grapes, :wines do |t|
      t.index :wine_id
      t.index :grape_id
      t.timestamps
    end
  end
end
