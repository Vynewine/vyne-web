class CreateMaturationTypes < ActiveRecord::Migration
  def change
    create_table :maturation_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
