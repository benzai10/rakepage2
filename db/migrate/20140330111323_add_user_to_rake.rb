class AddUserToRake < ActiveRecord::Migration
  def change
    add_column :rakes, :user_id, :integer
  end
end
