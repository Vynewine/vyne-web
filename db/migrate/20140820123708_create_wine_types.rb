class CreateWineTypes < ActiveRecord::Migration
  def change
    create_table :wine_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
