class AddFeaturedToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :featured, :boolean, default: false
  end
end
