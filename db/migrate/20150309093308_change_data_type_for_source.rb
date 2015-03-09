class ChangeDataTypeForSource < ActiveRecord::Migration
  def change
    change_column :channels, :source, :text
  end
end
