class CreateHeaps < ActiveRecord::Migration
  def change
    create_table :heaps do |t|

      t.integer :rake_id
      t.integer :leaflet_ids, array: true, default: []
      t.timestamps
    end
  end
end
