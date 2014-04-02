class Channel < ActiveRecord::Base
  after_create :pull_source

  validates :name, presence: true
  validates :channel_type, presence: true
  validates :source, presence: true

  has_many :channels_master_rakes, dependent: :destroy
  has_many :master_rakes, through: :channels_master_rakes, dependent: :destroy

  has_many :rake_channel_maps, dependent: :destroy
  has_many :rakes, through: :rake_channel_maps, dependent: :destroy

  def pull_source
    if self.channel_type == 0
      require 'feed_helper'
      feeds = Feedjira::Feed.fetch_and_parse [self.source]
      FeedHelper::Web.process_feeds(feeds)
    end
  end

end

