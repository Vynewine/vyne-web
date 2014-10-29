class CreateCompositions < ActiveRecord::Migration
  def change
    create_table :compositions do |t|
      t.string :name
      t.timestamps
    end

    create_table :composition_grapes do |t|
      t.references :composition, index: true
      t.references :grape, index: true
      t.integer :percentage
      t.timestamps
    end

    # add a foreign key
    execute <<-SQL
      ALTER TABLE composition_grapes
        ADD CONSTRAINT fk_composition_grapes_compositions
        FOREIGN KEY (composition_id)
        REFERENCES compositions(id)
    SQL


    execute <<-SQL
      ALTER TABLE composition_grapes
        ADD CONSTRAINT fk_composition_grapes_grapes
        FOREIGN KEY (grape_id)
        REFERENCES grapes(id)
    SQL
  end
end