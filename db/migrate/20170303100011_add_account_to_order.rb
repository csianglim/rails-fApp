class AddAccountToOrder < ActiveRecord::Migration[5.0]
  def change
    add_reference :orders, :account
  end
end
