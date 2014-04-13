class AddSaveCountToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :save_count, :integer, default: 0
    add_column :leaflets, :view_count, :integer, default: 0
  end
end
