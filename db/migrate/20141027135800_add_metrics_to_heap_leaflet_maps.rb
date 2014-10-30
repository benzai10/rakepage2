class AddMetricsToHeapLeafletMaps < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :motion_counter, :integer, default: 0
    add_column :heap_leaflet_maps, :action_counter, :integer, default: 0
    add_column :heap_leaflet_maps, :scheduled_counter, :integer, default: 0
  end
end
