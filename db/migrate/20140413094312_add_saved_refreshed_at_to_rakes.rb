class AddSavedRefreshedAtToRakes < ActiveRecord::Migration
  def change
    add_column :rakes, :saved_refreshed_at, :datetime
  end
end
