class CreateMasterHeaps < ActiveRecord::Migration
  def change
    create_table :master_heaps do |t|
      t.integer :master_rake_id
      t.integer :leaflet_type_id

      t.timestamps
    end
  end
end
