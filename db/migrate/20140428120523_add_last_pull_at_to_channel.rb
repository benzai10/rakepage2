class AddLastPullAtToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :last_pull_at, :datetime
  end
end
