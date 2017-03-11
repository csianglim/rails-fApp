class CreateSales < ActiveRecord::Migration[5.0]
  def change
    create_table :sales do |t|
      t.string :name
      t.text :description
      t.decimal :amount, precision: 10, scale: 2
      t.boolean :printed
      t.boolean :paid
      t.string :payee

      t.timestamps
    end
  end
end
