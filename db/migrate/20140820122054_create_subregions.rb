class CreateSubregions < ActiveRecord::Migration
  def change
    create_table :subregions do |t|
      t.string :name
      t.references :region, index: true

      t.timestamps
    end
  end
end
