class CreateProducers < ActiveRecord::Migration
  def change
    create_table :producers do |t|
      t.string :name
      t.references :country, index: true

      t.timestamps
    end
  end
end
