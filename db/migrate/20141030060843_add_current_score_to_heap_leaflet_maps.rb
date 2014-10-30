class AddCurrentScoreToHeapLeafletMaps < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :current_score, :integer, default: 0
    add_column :heap_leaflet_maps, :current_reminder, :integer, default: 0
  end
end
