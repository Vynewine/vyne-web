class CreateTypesWines < ActiveRecord::Migration
  def change
    create_table :types_wines do |t|
      t.integer :wine_id
      t.integer :type_id

      t.timestamps
    end
  end
end
