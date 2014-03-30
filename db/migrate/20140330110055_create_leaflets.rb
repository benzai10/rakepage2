class CreateLeaflets < ActiveRecord::Migration
  def change
    create_table :leaflets do |t|
      t.integer :channel_id
      t.string :content, null: false, default: ""
      t.timestamps
    end
  end
end
