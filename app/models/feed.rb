class Feed < ActiveRecord::Base

  belongs_to :myrake
  belongs_to :leaflet

  # Status Values:
  # 0: default
  # 1: liked
end
