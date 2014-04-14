class LeafletChangeColumnsToText < ActiveRecord::Migration
  def change
    change_column :leaflets, :identifier, :text
    change_column :leaflets, :title, :text
    change_column :leaflets, :url, :text
    change_column :leaflets, :author, :text
    change_column :leaflets, :image, :text
  end
end
