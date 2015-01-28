class AddHeaderToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :subtitle, :text
  end
end
