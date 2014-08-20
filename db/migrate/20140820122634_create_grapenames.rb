class CreateGrapenames < ActiveRecord::Migration
  def change
    create_table :grapenames do |t|
      t.string :name

      t.timestamps
    end
  end
end
