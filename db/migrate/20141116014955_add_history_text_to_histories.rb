class AddHistoryTextToHistories < ActiveRecord::Migration
  def change
    add_column :histories, :history_text, :text, default: ""
  end
end
