class AddCommentsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :comments, :text
  end
end
