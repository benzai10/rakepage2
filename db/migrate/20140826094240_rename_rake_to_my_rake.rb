class RenameRakeToMyRake < ActiveRecord::Migration
  def change
    rename_table :rakes, :myrakes
  end
end
