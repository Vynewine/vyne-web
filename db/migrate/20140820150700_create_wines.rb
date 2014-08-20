class CreateWines < ActiveRecord::Migration
  def change
    create_table :wines do |t|
      t.string :name
      t.integer :vintage
      t.string :area
      t.boolean :single_estate
      t.integer :alcohol
      t.integer :sugar
      t.integer :acidity
      t.integer :ph
      t.boolean :vegetarian
      t.boolean :vegan
      t.boolean :organic
      t.integer :producer_id
      t.integer :subregion_id
      t.integer :appellation_id
      t.integer :maturation_id

      t.timestamps
    end
  end
end
