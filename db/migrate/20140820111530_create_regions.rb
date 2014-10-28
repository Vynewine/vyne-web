class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.references :country, index: true
      t.timestamps
    end

    # add a foreign key
    execute <<-SQL
      ALTER TABLE regions
        ADD CONSTRAINT fk_regions_countries
        FOREIGN KEY (country_id)
        REFERENCES countries(id)
    SQL
  end
end
