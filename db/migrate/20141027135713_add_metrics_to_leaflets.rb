class AddMetricsToLeaflets < ActiveRecord::Migration
  def change
    add_column :leaflets, :motion_counter, :integer, default: 0
    add_column :leaflets, :action_counter, :integer, default: 0
    add_column :leaflets, :scheduled_counter, :integer, default: 0
  end
end
