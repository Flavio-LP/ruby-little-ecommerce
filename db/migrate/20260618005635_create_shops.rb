class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :shops, :slug, unique: true
  end
end
