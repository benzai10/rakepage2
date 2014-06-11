class AddCreatedByToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :created_by, :integer
  end
end
