class Channel < ActiveRecord::Base
  require 'feed_helper'
  before_validation :analyze_source, on: :create

  validates :source, presence: true, :uniqueness => {:case_sensitive => false}
  validates :name, presence: true
  validates :channel_type, presence: true

  has_many :channels_master_rakes, dependent: :destroy
  has_many :master_rakes, through: :channels_master_rakes, dependent: :destroy

  has_many :rake_channel_maps, dependent: :destroy
  has_many :rakes, through: :rake_channel_maps, dependent: :destroy

  def pull_source
    if self.channel_type == 0
      feeds = Feedjira::Feed.fetch_and_parse [self.source]
      FeedHelper::Web.process_feeds(feeds)
    end
  end

  private

  def analyze_source
    if source =~ URI::regexp

      self.channel_type = 0
      if self.name.blank?
        self.name = FeedHelper::Spike.detect_title(source)
      end

      feed_url = FeedHelper::Spike.detect_feed(source)
      unless feed_url.nil? 
        self.source = feed_url.first
      end
    end
  end

end

