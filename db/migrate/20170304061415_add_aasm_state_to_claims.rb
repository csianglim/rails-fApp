class AddAasmStateToClaims < ActiveRecord::Migration[5.0]
  def change
    add_column :claims, :aasm_state, :string
  end
end
