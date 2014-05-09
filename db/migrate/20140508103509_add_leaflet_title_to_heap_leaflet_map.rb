class AddLeafletTitleToHeapLeafletMap < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :leaflet_title, :text
  end
end
