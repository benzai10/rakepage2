class Category < ActiveRecord::Base
  #belongs_to :master_rake
  has_many :category_leaflet_type_maps, dependent: :destroy
  has_many :leaflet_types, through: :category_leaflet_type_maps, dependent: :destroy

  def add_leaflet_type(leaflet_type)
    self.leaflet_types << leaflet_type
  end

end
