class Leaflet < ActiveRecord::Base
  attr_accessor :rake_id

  validates :channel_id, presence: true
  validates :url, :format => URI::regexp(%w(http https))
  #validates :content, presence: true

  belongs_to :channel
  has_many :feeds, dependent: :destroy
end
