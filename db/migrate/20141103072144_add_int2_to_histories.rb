class AddInt2ToHistories < ActiveRecord::Migration
  def change
    add_column :histories, :history_int2, :integer, default: 0
  end
end
