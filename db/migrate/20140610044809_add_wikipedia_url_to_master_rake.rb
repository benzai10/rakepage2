class AddWikipediaUrlToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :wikipedia_url, :string
  end
end
