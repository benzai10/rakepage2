class MasterHeapLeafletMap < ActiveRecord::Base
  validates :master_heap_id, presence: true
  validates :leaflet_id, presence: true
  validates_uniqueness_of :leaflet_id, :scope => :master_heap_id

  belongs_to :master_heap
  belongs_to :leaflet

end
