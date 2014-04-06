class Leaflet < ActiveRecord::Base
  attr_accessor :rake_id

  validates :channel_id, presence: true
  validates :content, presence: true

  belongs_to :channel
end
