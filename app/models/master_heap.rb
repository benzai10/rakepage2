class MasterHeap < ActiveRecord::Base
  validates :master_rake_id, presence: true
  validates_uniqueness_of :leaflet_type_id, :scope => :master_rake_id

  belongs_to :master_rake

  has_many :master_heap_leaflet_maps, dependent: :destroy
  has_many :leaflets, through: :master_heap_leaflet_maps

end
