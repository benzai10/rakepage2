class AddCommentToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :comment, :text, default: ""
  end
end
