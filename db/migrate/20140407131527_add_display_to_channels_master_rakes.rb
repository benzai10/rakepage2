class AddDisplayToChannelsMasterRakes < ActiveRecord::Migration
  def change
    add_column :channels_master_rakes, :display, :boolean, default: true
  end
end
