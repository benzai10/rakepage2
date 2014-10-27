class AddTopRakeToMyrakes < ActiveRecord::Migration
  def change
    add_column :myrakes, :top_rake, :integer, default: 0
  end
end