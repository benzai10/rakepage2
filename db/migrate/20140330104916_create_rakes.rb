class CreateRakes < ActiveRecord::Migration
  def change

    create_table :rakes do |t|
      t.string :name, null: false, default: ""
      t.integer :master_rake_id
      t.timestamps
    end

  end
end
