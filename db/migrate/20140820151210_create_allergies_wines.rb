class CreateAllergiesWines < ActiveRecord::Migration
  def change
    create_table :allergies_wines do |t|
      t.integer :wine_id
      t.integer :allergy_id

      t.timestamps
    end
  end
end
