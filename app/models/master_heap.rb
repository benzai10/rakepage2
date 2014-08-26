class MasterHeap < ActiveRecord::Base
  validates :master_rake_id, presence: true

  belongs_to :master_rake

  has_many :master_heap_leaflet_maps, dependent: :destroy
  has_many :leaflets, through: :master_heap_leaflet_maps

end
