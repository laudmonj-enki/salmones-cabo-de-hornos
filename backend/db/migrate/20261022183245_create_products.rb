class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.integer :catalog_number, null: false
      t.string  :name,           null: false
      t.string  :category,       null: false
      t.string  :presentation
      t.string  :unit,           null: false
      t.integer :net_price_clp,  null: false
      t.boolean :active,         null: false, default: true

      t.timestamps
    end

    add_index :products, :catalog_number, unique: true
    add_check_constraint :products, "net_price_clp >= 0",
                         name: "products_net_price_clp_non_negative"
  end
end
