class AddVendorToClaims < ActiveRecord::Migration[5.0]
  def change
    add_column :claims, :vendor, :string
  end
end
