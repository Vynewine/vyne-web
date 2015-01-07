class AddMerchantPriceToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :merchant_price_min, :numeric
    add_column :categories, :merchant_price_max, :numeric

    db.execute "UPDATE categories SET merchant_price_min = 0.00 WHERE id = 1"
    db.execute "UPDATE categories SET merchant_price_max = 8.50 WHERE id = 1"

    db.execute "UPDATE categories SET merchant_price_min = 8.51 WHERE id = 2"
    db.execute "UPDATE categories SET merchant_price_max = 13.00 WHERE id = 2"

    db.execute "UPDATE categories SET merchant_price_min = 13.01 WHERE id = 3"
    db.execute "UPDATE categories SET merchant_price_max = 23.00 WHERE id = 3"

    db.execute "UPDATE categories SET merchant_price_min = 23.01 WHERE id = 4"
    db.execute "UPDATE categories SET merchant_price_max = 40.00 WHERE id = 4"
  end

  def db
    ActiveRecord::Base.connection
  end
end
