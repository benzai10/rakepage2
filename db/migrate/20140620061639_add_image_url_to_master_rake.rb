class AddImageUrlToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :image_url, :text
  end
end
