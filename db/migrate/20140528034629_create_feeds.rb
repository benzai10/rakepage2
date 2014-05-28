class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.integer :rake_id
      t.integer :leaflet_id
      t.integer :status, default: 0
      t.datetime :last_pull_at

      t.timestamps
    end
  end
end
