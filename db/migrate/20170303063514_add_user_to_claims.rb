class AddUserToClaims < ActiveRecord::Migration[5.0]
  def change
    add_reference :claims, :user, foreign_key: true
  end
end
