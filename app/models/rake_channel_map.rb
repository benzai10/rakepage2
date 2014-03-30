class RakeChannelMap < ActiveRecord::Base
  validates :channel_id, presence: true
  validates :rake_id, presence: true
  validates_uniqueness_of :rake_id, :scope => :channel_id

  belongs_to :rake
  belongs_to :channel
end
