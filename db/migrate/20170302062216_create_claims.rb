class CreateClaims < ActiveRecord::Migration[5.0]
  def change
    create_table :claims do |t|
      t.string :name
      t.text :description
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
