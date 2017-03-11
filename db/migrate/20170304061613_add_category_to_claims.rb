class AddCategoryToClaims < ActiveRecord::Migration[5.0]
  def change
    add_column :claims, :category, :string
  end
end
