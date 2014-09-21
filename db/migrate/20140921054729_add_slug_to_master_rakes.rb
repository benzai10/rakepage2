class AddSlugToMasterRakes < ActiveRecord::Migration
  def change
    add_column :master_rakes, :slug, :string
    add_index :master_rakes, :slug, unique: true
  end
end
