class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :shop, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.string :sku
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
