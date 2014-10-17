class CreateWines < ActiveRecord::Migration
  def change
    create_table :wines do |t|
      t.string :name
      t.integer :vintage
      t.string :area
      t.boolean :single_estate
      t.integer :cost
      t.integer :alcohol
      t.integer :sugar
      t.integer :acidity
      t.integer :ph
      t.boolean :vegan
      t.boolean :organic

      t.references :producer, index: true
      t.references :subregion, index: true
      t.references :appellation, index: true
      t.references :maturation, index: true

      t.timestamps
    end
    add_index :wines, :name
    add_index :wines, :vintage
  end
end
