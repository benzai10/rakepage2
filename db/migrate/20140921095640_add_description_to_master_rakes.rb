class AddDescriptionToMasterRakes < ActiveRecord::Migration
  def change
    add_column :master_rakes, :description, :string
  end
end
