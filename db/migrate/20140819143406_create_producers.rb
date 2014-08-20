class CreateProducers < ActiveRecord::Migration
  def change
    create_table :producers do |t|
      t.string :name
      t.integer :country_id

      t.timestamps
    end
  end
end
