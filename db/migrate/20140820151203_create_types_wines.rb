class CreateTypesWines < ActiveRecord::Migration
  def change
    # create_table :types_wines do |t|
    create_join_table :types, :wines do |t|
      t.index :type_id # t.index t.integer
      t.index :wine_id
      t.timestamps
    end
    # add_index :types_wines, :type_id
    # add_index :types_wines, :wine_id
    # add_index :types_wines, [:type_id, :wine_id], unique: true
  end
end
