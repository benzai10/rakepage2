class AddLastPullAtToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :last_pull_at, :datetime, default: Time.now - 1200
  end
end
