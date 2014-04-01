class AddPublishedToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :published_at, :datetime
  end
end
