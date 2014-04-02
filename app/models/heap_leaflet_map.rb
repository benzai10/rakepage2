class HeapLeafletMap < ActiveRecord::Base
  validates :heap_id, presence: true
  validates :leaflet_id, presence: true

  belongs_to :heap
  belongs_to :leaflet
end
