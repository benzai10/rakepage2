class AddLeafletTypeIdToHeapLeafletMap < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :leaflet_type_id, :integer, default: 0
  end
end
