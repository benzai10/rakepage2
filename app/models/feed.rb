class Feed < ActiveRecord::Base

  belongs_to :rake
  belongs_to :leaflet

  # Status Values:
  # 0: default
  # 1: liked

  def get_leaflets
    
  end

  def delete_leaflets
  end
end
