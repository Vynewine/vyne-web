class CreateAllergiesWines < ActiveRecord::Migration
  def change
    create_join_table :allergies, :wines do |t|
      t.index :wine_id
      t.index :allergy_id
      t.timestamps
    end
  end
end
