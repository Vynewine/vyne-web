class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :warehouse, index: true
      t.references :client, index: true
      t.references :advisor, index: true
      t.references :address, index: true
      t.references :payment, index: true
      t.references :status, index: true
      t.string :delivery_token
      t.json :information
      t.json :delivery_status

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE orders
        ADD CONSTRAINT fk_orders_payments
        FOREIGN KEY (payment_id)
        REFERENCES payments(id)
    SQL

    execute <<-SQL
      ALTER TABLE orders
        ADD CONSTRAINT fk_orders_addresses
        FOREIGN KEY (address_id)
        REFERENCES addresses(id)
    SQL

    execute <<-SQL
      ALTER TABLE orders
        ADD CONSTRAINT fk_orders_users
        FOREIGN KEY (client_id)
        REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE orders
        ADD CONSTRAINT fk_orders_advisors
        FOREIGN KEY (advisor_id)
        REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE orders
        ADD CONSTRAINT fk_orders_statuses
        FOREIGN KEY (status_id)
        REFERENCES statuses(id)
    SQL

  end
end
