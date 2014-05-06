class CreateLeafletTypes < ActiveRecord::Migration
  def change
    create_table :leaflet_types do |t|
      t.integer :leaflet_type, default: 0
      t.string :leaflet_type_desc, default: "Uncategorized"

      t.timestamps
    end
  end
end
