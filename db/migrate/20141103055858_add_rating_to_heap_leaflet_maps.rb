class AddRatingToHeapLeafletMaps < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :current_rating, :integer, default: 0
  end
end
