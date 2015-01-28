class AddExternalLinkToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :ext_link, :boolean
  end
end
