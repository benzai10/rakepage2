class Leaflet < ActiveRecord::Base
  validates :channel_id, presence: true
  validates :content, presence: true

  belongs_to :channel
end
