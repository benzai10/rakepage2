class AddGoalAndNoteToHeapLeafletMaps < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :leaflet_goal, :string, default: ""
    add_column :heap_leaflet_maps, :leaflet_note, :text, default: ""
  end
end
