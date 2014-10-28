class CreateProducers < ActiveRecord::Migration
  def change
    create_table :producers do |t|
      t.string :name
      t.references :country, index: true
      t.text :note
      t.timestamps
    end

    # add a foreign key
    execute <<-SQL
      ALTER TABLE producers
        ADD CONSTRAINT fk_producers_countries
        FOREIGN KEY (country_id)
        REFERENCES countries(id)
    SQL

  end
end
