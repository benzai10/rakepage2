class CreateMasterRakesChannels < ActiveRecord::Migration
  def change
    create_table :channels_master_rakes do |t|
      t.belongs_to :master_rake
      t.belongs_to :channel
    end
  end
end
