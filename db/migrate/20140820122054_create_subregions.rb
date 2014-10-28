class CreateSubregions < ActiveRecord::Migration
  def change
    create_table :subregions do |t|
      t.string :name
      t.references :region, index: true

      t.timestamps
    end

    # add a foreign key
    execute <<-SQL
      ALTER TABLE subregions
        ADD CONSTRAINT fk_subregions_regions
        FOREIGN KEY (region_id)
        REFERENCES regions(id)
    SQL
  end
end
