class CreateWineOccasions < ActiveRecord::Migration
  def change
    create_table :wine_occasions do |t|
      t.string :name

      t.timestamps
    end
  end
end
