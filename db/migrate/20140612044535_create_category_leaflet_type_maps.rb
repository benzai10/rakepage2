class CreateCategoryLeafletTypeMaps < ActiveRecord::Migration
  def change
    create_table :category_leaflet_type_maps do |t|
      t.integer :category_id
      t.integer :leaflet_type_id

      t.timestamps
    end
  end
end
