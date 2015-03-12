class AddPublicChannelToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :public_channel, :boolean, default: false
  end
end
