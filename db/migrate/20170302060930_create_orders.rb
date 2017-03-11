class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity
      t.string :supplier
      t.string :link
      t.string :part_number

      t.timestamps
    end
  end
end
