class AddValuesToHistories < ActiveRecord::Migration
  def change
    add_column :histories, :history_int, :integer, default: 0
    add_column :histories, :history_str, :string, default: ""
  end
end
