class AddTitleToLeaflet < ActiveRecord::Migration
  def change
    add_column :leaflets, :identifier, :string
    add_column :leaflets, :title, :string
    add_column :leaflets, :url, :string
    add_column :leaflets, :author, :string
    add_column :leaflets, :image, :string

    add_index "leaflets", ["identifier"], name: "index_leaflets_on_identifiers", unique: true, using: :btree

  end
end
