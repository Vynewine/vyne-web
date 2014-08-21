class CreateBottlings < ActiveRecord::Migration
  def change
    create_table :bottlings do |t|
      t.string :name

      t.timestamps
    end
  end
end
