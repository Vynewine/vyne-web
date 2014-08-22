class CreateNotesWines < ActiveRecord::Migration
  def change
    create_join_table :notes, :wines do |t|
      t.index :wine_id
      t.index :note_id
      t.timestamps
    end
  end
end
