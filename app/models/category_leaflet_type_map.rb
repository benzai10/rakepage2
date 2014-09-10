class CategoryLeafletTypeMap < ActiveRecord::Base
  belongs_to :category
  belongs_to :leaflet_type
end
