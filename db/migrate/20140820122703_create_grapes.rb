class CreateGrapes < ActiveRecord::Migration
  def change
    create_table :grapes do |t|
      t.integer :grapename_id
      t.integer :quantity

      t.timestamps
    end
  end
end
