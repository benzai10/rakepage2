class AddLikeCountToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :like_count, :integer, default: 0
  end
end
