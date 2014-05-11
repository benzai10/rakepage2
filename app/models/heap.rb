class Heap < ActiveRecord::Base
  attr_accessor :leaflet_id

  validates :rake_id, presence: true

  belongs_to :rake

  has_many :heap_leaflet_maps, dependent: :destroy
  has_many :leaflets, through: :heap_leaflet_maps, dependent: :destroy


  def add_leaflet(leaflet, leaflet_type_id, leaflet_title, leaflet_desc)
    self.heap_leaflet_maps.create(leaflet_id: leaflet.id,
                                  leaflet_type_id: leaflet_type_id,
                                  leaflet_title: leaflet_title,
                                  leaflet_desc: leaflet_desc)
    Leaflet.find(leaflet.id).update!(save_count: leaflet.save_count+1)
  end

  def remove_leaflet(leaflet)
    self.heap_leaflet_maps.find_by(leaflet_id: leaflet.id).destroy
    if self.heap_leaflet_maps.empty?
      self.destroy
    end
    Leaflet.find(leaflet.id).update!(save_count: leaflet.save_count-1)
  end

end
