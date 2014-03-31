class CreateMasterRakesChannels < ActiveRecord::Migration
  def change
    create_table :channels_master_rakes do |t|
      t.belongs_to :master_rake
      t.belongs_to :channel
    end

    add_index "channels_master_rakes", ["channel_id", "master_rake_id"], name: "index_channel_master_rake_on_master_rake_id_and_channel_id", unique: true, using: :btree
  end
end
