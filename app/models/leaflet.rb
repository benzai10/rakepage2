class Leaflet < ActiveRecord::Base
  attr_accessor :rake_id
  attr_accessor :leaflet_desc

  validates :channel_id, presence: true
  validates :url, :format => URI::regexp(%w(http https))
  #validates :content, presence: true

  belongs_to :channel
  has_many :feeds, dependent: :destroy

  scope :newly_added, -> { where.not(leaflet_type_id: 15).where.not(save_count: 0).order(created_at: :desc).limit(50) }
end
