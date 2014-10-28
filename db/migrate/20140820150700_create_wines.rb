class CreateWines < ActiveRecord::Migration
  def change
    create_table :wines do |t|
      t.string :name
      t.string :wine_key
      t.integer :vintage
      t.boolean :single_estate
      t.decimal :alcohol
      t.references :producer, index: true
      t.references :region, index: true
      t.references :subregion, index: true
      t.references :locale, index: true
      t.references :appellation, index: true
      t.references :maturation, index: true
      t.references :type, index: true
      t.references :vinification, index: true
      t.references :composition, index: true
      t.text :note
      t.decimal :bottle_size

      t.timestamps
    end
    add_index :wines, :name
    add_index :wines, :vintage
    add_index :wines, :wine_key, :unique => true
  end
end
