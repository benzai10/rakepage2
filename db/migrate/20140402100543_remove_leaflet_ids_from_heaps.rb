class RemoveLeafletIdsFromHeaps < ActiveRecord::Migration
  def change
    remove_column :heaps, :leaflet_ids

    create_table :heap_leaflet_maps do |t|
      t.integer :heap_id
      t.integer :leaflet_id

      t.timestamps
    end

    add_index "heap_leaflet_maps", ["heap_id", "leaflet_id"], name: "index_heap_leaflet_maps_on_heap_id_and_leaflet_id", unique: true, using: :btree
  end
end
