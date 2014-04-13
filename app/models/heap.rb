class Heap < ActiveRecord::Base
  validates :rake_id, presence: true

  belongs_to :rake

  has_many :heap_leaflet_maps, dependent: :destroy
  has_many :leaflets, through: :heap_leaflet_maps, dependent: :destroy


  def add_leaflet(leaflet)
    self.heap_leaflet_maps.create(leaflet_id: leaflet.id)
    Leaflet.increment_counter(:save_count, leaflet.id)
  end

  def remove_leaflet(leaflet)
    self.heap_leaflet_maps.find_by(leaflet_id: leaflet.id).destroy
    Leaflet.decrement_counter(:save_count, leaflet.id)
  end

end
