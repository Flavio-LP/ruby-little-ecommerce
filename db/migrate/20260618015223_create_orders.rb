class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :total_cents, null: false

      t.timestamps
    end
  end
end
