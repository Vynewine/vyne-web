class CreateAppellations < ActiveRecord::Migration
  def change
    create_table :appellations do |t|
      t.string :name
      t.string :classification
      t.references :region
      t.timestamps
    end

    # add a foreign key
    execute <<-SQL
      ALTER TABLE appellations
        ADD CONSTRAINT fk_appellations_regions
        FOREIGN KEY (region_id)
        REFERENCES regions(id)
    SQL
  end
end
