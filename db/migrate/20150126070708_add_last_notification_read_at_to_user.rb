class AddLastNotificationReadAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_notification_read_at, :datetime
  end
end
