class AddSeoTitleToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :seo_title, :string, default: ""
  end
end
