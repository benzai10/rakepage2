class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :keyword
      t.integer :filter_type
      t.integer :rake_id

      t.timestamps
    end
  end
end
