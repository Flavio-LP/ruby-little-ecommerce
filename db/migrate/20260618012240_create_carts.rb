class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :guest_token

      t.timestamps
    end

    add_index :carts, :guest_token
  end
end
