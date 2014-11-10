class AddDeletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at

    add_column :addresses, :deleted_at, :datetime
    add_index :addresses, :deleted_at

    add_column :payments, :deleted_at, :datetime
    add_index :payments, :deleted_at

    add_column :wines, :deleted_at, :datetime
    add_index :wines, :deleted_at

    add_column :warehouses, :deleted_at, :datetime
    add_index :warehouses, :deleted_at

    add_column :vinifications, :deleted_at, :datetime
    add_index :vinifications, :deleted_at

    add_column :types, :deleted_at, :datetime
    add_index :types, :deleted_at

    add_column :subscribers, :deleted_at, :datetime
    add_index :subscribers, :deleted_at

    add_column :subregions, :deleted_at, :datetime
    add_index :subregions, :deleted_at

    add_column :statuses, :deleted_at, :datetime
    add_index :statuses, :deleted_at

    add_column :roles, :deleted_at, :datetime
    add_index :roles, :deleted_at

    add_column :regions, :deleted_at, :datetime
    add_index :regions, :deleted_at

    add_column :producers, :deleted_at, :datetime
    add_index :producers, :deleted_at

    add_column :preparations, :deleted_at, :datetime
    add_index :preparations, :deleted_at

    add_column :order_items, :deleted_at, :datetime
    add_index :order_items, :deleted_at

    add_column :occasions, :deleted_at, :datetime
    add_index :occasions, :deleted_at

    add_column :maturations, :deleted_at, :datetime
    add_index :maturations, :deleted_at

    add_column :mailing_lists, :deleted_at, :datetime
    add_index :mailing_lists, :deleted_at

    add_column :locales, :deleted_at, :datetime
    add_index :locales, :deleted_at

    add_column :inventories, :deleted_at, :datetime
    add_index :inventories, :deleted_at

    add_column :grapes, :deleted_at, :datetime
    add_index :grapes, :deleted_at

    add_column :foods, :deleted_at, :datetime
    add_index :foods, :deleted_at

    add_column :food_items, :deleted_at, :datetime
    add_index :food_items, :deleted_at

    add_column :countries, :deleted_at, :datetime
    add_index :countries, :deleted_at

    add_column :compositions, :deleted_at, :datetime
    add_index :compositions, :deleted_at

    add_column :composition_grapes, :deleted_at, :datetime
    add_index :composition_grapes, :deleted_at

    add_column :categories, :deleted_at, :datetime
    add_index :categories, :deleted_at

    add_column :bottlings, :deleted_at, :datetime
    add_index :bottlings, :deleted_at

    add_column :appellations, :deleted_at, :datetime
    add_index :appellations, :deleted_at

    add_column :addresses_users, :deleted_at, :datetime
    add_index :addresses_users, :deleted_at

  end
end
