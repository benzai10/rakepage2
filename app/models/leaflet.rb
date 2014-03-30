class Leaflet < ActiveRecord::Base
  validates :channel_id, presence: true
  validates :content, presence: true
end
