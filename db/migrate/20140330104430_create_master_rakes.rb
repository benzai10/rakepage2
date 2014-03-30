class CreateMasterRakes < ActiveRecord::Migration
  def change

    create_table :master_rakes do |t|
      t.string :name, null: false, default: ""
      t.timestamps
    end

    add_index :master_rakes, :name, unique: true
  end
end
