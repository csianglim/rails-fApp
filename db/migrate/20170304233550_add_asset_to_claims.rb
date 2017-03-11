class AddAssetToClaims < ActiveRecord::Migration[5.0]
  def change
    add_column :claims, :asset, :string
  end
end
