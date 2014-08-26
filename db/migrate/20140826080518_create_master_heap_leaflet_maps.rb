class CreateMasterHeapLeafletMaps < ActiveRecord::Migration
  def change
    create_table :master_heap_leaflet_maps do |t|
      t.integer :master_heap_id
      t.integer :leaflet_id
      t.text :leaflet_desc

      t.timestamps
    end
  end
end
