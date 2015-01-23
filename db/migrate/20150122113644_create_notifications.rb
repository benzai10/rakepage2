class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :body
      t.integer :notification_type
      t.text :user_ids
      t.text :master_rake_ids
      t.datetime :published_at

      t.timestamps
    end
  end
end
