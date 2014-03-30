class CreateRakeChannelMaps < ActiveRecord::Migration
  def change
    create_table :rake_channel_maps do |t|

      t.integer :channel_id
      t.integer :rake_id
      t.string :options, null: false, default: ""
      t.timestamps
    end
  end
end
