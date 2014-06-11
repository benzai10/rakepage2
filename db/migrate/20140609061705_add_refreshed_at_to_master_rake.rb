class AddRefreshedAtToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :refreshed_at, :datetime
  end
end
