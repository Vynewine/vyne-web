class CreateNotesWines < ActiveRecord::Migration
  def change
    create_table :notes_wines do |t|
      t.integer :wine_id
      t.integer :note_id

      t.timestamps
    end
  end
end
