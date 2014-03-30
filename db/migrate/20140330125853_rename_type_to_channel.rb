class RenameTypeToChannel < ActiveRecord::Migration
  def change
    rename_column :channels, :type, :channel_type
  end
end
