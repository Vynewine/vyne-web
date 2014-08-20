class CreateAppellations < ActiveRecord::Migration
  def change
    create_table :appellations do |t|
      t.string :name

      t.timestamps
    end
  end
end
