class AddRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :superadmin_role, :boolean, default: false
    add_column :users, :supervisor_role, :boolean, default: false
    add_column :users, :manager_role, :boolean, default: false
    add_column :users, :logistics_role, :boolean, default: false
    add_column :users, :approver_role, :boolean, default: false
    add_column :users, :user_role, :boolean, default: true
  end
end
