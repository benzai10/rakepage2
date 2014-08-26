class RakeChannelMap < ActiveRecord::Base
  validates :channel_id, presence: true
  validates :myrake_id, presence: true
  validates_uniqueness_of :myrake_id, :scope => :channel_id

  belongs_to :myrake
  belongs_to :channel
end
