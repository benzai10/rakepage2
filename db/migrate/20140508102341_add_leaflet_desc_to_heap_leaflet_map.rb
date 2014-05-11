class AddLeafletDescToHeapLeafletMap < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :leaflet_desc, :text
  end
end
