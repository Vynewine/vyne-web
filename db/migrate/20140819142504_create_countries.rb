class CreateCountries < ActiveRecord::Migration
  # Ref:
  # http://stefangabos.ro/other-projects/list-of-world-countries-with-national-flags/#download
  #
  def change
    create_table :countries do |t|
      t.string :name
      t.string :alpha_2
      t.string :alpha_3

      t.timestamps
    end
  end

end
