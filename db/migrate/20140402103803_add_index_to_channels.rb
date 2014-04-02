class AddIndexToChannels < ActiveRecord::Migration
  def change
    add_index :channels, :source, unique: true
  end
end
