class AddLeafletTypeIdToHeap < ActiveRecord::Migration
  def change
    add_column :heaps, :leaflet_type_id, :integer, default: 0
  end
end
