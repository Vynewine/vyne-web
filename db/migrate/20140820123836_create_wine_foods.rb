class CreateWineFoods < ActiveRecord::Migration
  def change
    create_table :wine_foods do |t|
      t.string :name

      t.timestamps
    end
  end
end
