class AddDeleteCountToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :delete_count, :integer, default: 0
  end
end
