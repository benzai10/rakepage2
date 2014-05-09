class AddCategoryIdToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :category_id, :integer, default: 1
  end
end
