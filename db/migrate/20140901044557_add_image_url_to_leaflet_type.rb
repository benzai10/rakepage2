class AddImageUrlToLeafletType < ActiveRecord::Migration
  def change
    add_column :leaflet_types, :image_url, :text
  end
end
