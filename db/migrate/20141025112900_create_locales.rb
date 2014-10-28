class CreateLocales < ActiveRecord::Migration
  def change
    create_table :locales do |t|
      t.string :name
      t.references :subregion, index: true
      t.text :note

      t.timestamps
    end

    # add a foreign key
    execute <<-SQL
      ALTER TABLE locales
        ADD CONSTRAINT fk_locales_subregions
        FOREIGN KEY (subregion_id)
        REFERENCES subregions(id)
    SQL
  end
end
