class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :desc

      t.timestamps
    end
  end
end
