class AddRefreshToRake < ActiveRecord::Migration
  def change
    add_column :rakes, :refreshed_at, :datetime
  end
end
