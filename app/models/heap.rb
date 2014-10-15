class Heap < ActiveRecord::Base
  attr_accessor :leaflet_id

  validates :myrake_id, presence: true
  validates_uniqueness_of :leaflet_type_id, :scope => :myrake_id

  belongs_to :myrake

  has_many :heap_leaflet_maps, dependent: :destroy
  has_many :leaflets, through: :heap_leaflet_maps, dependent: :destroy


  def add_leaflet(leaflet, leaflet_type_id, leaflet_title, leaflet_desc, reminder)
    begin 
      self.heap_leaflet_maps.create(leaflet_id: leaflet.id,
                                  leaflet_type_id: leaflet_type_id,
                                  leaflet_title: leaflet_title,
                                  leaflet_desc: leaflet_desc,
                                  reminder_at: reminder)
      Leaflet.find(leaflet.id).update!(save_count: leaflet.save_count+1)
    rescue
      nil
    end
  end

  def remove_leaflet(leaflet)
    self.heap_leaflet_maps.find_by(leaflet_id: leaflet.id).destroy
    leaflet = Leaflet.find(leaflet.id)
    leaflet.update!(save_count: leaflet.save_count-1, delete_count: leaflet.delete_count+1)
    if leaflet.save_count == 0
      master_heap = self.myrake.master_rake.master_heaps.where(leaflet_type_id: self.leaflet_type_id).first
      if !master_heap.nil?
        leaflet_map = MasterHeapLeafletMap.where(master_heap_id: master_heap.id, leaflet_id: leaflet.id).first
        if !leaflet_map.nil?
          leaflet_map.destroy
        end
      end
    end
  end

  def move_leaflet(leaflet, rake, heap)
  end
end
