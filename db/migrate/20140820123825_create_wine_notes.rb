class CreateWineNotes < ActiveRecord::Migration
  def change
    create_table :wine_notes do |t|
      t.string :name

      t.timestamps
    end
  end
end
