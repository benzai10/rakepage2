class ChannelsMasterRake < ActiveRecord::Base
  validates :channel_id, presence: true
  validates :master_rake_id, presence: true
  validates_uniqueness_of :master_rake_id, :scope => :channel_id

  belongs_to :channel
  belongs_to :master_rake
end
