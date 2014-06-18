class AddWikipediaFirstParagraphToMasterRake < ActiveRecord::Migration
  def change
    add_column :master_rakes, :wikipedia_first_paragraph, :text
  end
end
