class AddEnumToChannel < ActiveRecord::Migration
  def change

    remove_column :channels, :channel_type
    add_column :channels, :channel_type, :integer

  end
end
