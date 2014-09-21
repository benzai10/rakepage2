class AddSlugToMyrakes < ActiveRecord::Migration
  def change
    add_column :myrakes, :slug, :string
    add_index :myrakes, :slug, unique: true
  end
end
