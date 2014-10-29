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

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_producers
        FOREIGN KEY (producer_id)
        REFERENCES producers(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_regions
        FOREIGN KEY (region_id)
        REFERENCES regions(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_subregions
        FOREIGN KEY (subregion_id)
        REFERENCES subregions(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_locales
        FOREIGN KEY (locale_id)
        REFERENCES locales(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_appellations
        FOREIGN KEY (appellation_id)
        REFERENCES appellations(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_maturations
        FOREIGN KEY (maturation_id)
        REFERENCES maturations(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_types
        FOREIGN KEY (type_id)
        REFERENCES types(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_vinifications
        FOREIGN KEY (vinification_id)
        REFERENCES vinifications(id)
    SQL

    execute <<-SQL
      ALTER TABLE wines
        ADD CONSTRAINT fk_wines_compositions
        FOREIGN KEY (composition_id)
        REFERENCES compositions(id)
    SQL

  end
end
