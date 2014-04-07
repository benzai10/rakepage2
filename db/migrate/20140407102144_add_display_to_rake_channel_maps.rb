class AddDisplayToRakeChannelMaps < ActiveRecord::Migration
  def change
    add_column :rake_channel_maps, :display, :boolean, default: true
  end
end
