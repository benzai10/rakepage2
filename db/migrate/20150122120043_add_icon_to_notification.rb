class AddIconToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :icon, :string
  end
end
