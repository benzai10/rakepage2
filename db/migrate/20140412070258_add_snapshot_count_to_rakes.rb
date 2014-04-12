class AddSnapshotCountToRakes < ActiveRecord::Migration
  def change
    add_column :rakes, :snapshot_count, :integer, default: 0
  end
end
