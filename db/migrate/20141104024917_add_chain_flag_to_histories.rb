class AddChainFlagToHistories < ActiveRecord::Migration
  def change
    add_column :histories, :history_chain, :integer, default: 0
  end
end
