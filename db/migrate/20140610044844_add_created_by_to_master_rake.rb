class AddCreatedByToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :created_by, :integer
  end
end
