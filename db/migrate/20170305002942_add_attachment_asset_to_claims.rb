class AddAttachmentAssetToClaims < ActiveRecord::Migration
  def self.up
    change_table :claims do |t|
      t.attachment :asset
    end
  end

  def self.down
    remove_attachment :claims, :asset
  end
end
