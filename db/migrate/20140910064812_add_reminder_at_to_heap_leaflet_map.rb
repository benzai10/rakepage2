class AddReminderAtToHeapLeafletMap < ActiveRecord::Migration
  def change
    add_column :heap_leaflet_maps, :reminder_at, :datetime
  end
end
