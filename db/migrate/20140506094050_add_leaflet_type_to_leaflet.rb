class AddLeafletTypeToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :leaflet_type_id, :integer, default: 0
  end
end
