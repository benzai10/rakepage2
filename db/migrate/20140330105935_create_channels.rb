class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.string :source, null: false, default: ""
      t.timestamps
    end
  end
end
