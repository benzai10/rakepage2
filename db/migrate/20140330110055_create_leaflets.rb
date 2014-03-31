class CreateLeaflets < ActiveRecord::Migration
  def change
    create_table :leaflets do |t|
      t.integer :channel_id
      t.text :content, null: false, default: ""
      t.timestamps
    end
  end
end
