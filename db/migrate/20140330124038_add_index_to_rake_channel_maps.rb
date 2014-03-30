class AddIndexToRakeChannelMaps < ActiveRecord::Migration
  def change
    add_index "rake_channel_maps", ["channel_id"], name: "index_rake_channel_maps_on_channel_id", using: :btree
    add_index "rake_channel_maps", ["rake_id", "channel_id"], name: "index_rake_channel_maps_on_rake_id_and_channel_id", unique: true, using: :btree
    add_index "rake_channel_maps", ["rake_id"], name: "index_rake_channel_maps_on_rake_id", using: :btree
  end
end
