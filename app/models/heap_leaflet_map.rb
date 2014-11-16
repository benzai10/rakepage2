class HeapLeafletMap < ActiveRecord::Base
  validates :heap_id, presence: true
  validates :leaflet_id, presence: true
  validates :leaflet_type_id, presence: true
  validates :leaflet_goal, length: { maximum: 300 }
  validates :leaflet_note, length: { maximum: 4000 }

  belongs_to :heap
  belongs_to :leaflet
end
