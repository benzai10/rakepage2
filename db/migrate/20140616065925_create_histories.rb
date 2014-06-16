class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.integer :user_id
      t.integer :master_rake_id
      t.integer :rake_id
      t.integer :heap_id
      t.integer :channel_id
      t.integer :leaflet_id
      t.integer :user_relation_id
      t.string :history_code

      t.timestamps
    end
  end
end
