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


  def self.create_channels(urls)
    urls.each do |url|
      begin
        Channel.create!(source: url)
      rescue FeedHelper::FeedNotFoundError => e
        p e.message
      rescue URI::InvalidURIError => e
        p e.message
      rescue ActiveRecord::RecordInvalid => e
        p e.message
        p url
      end
    end
  end


  def pull_source
    if self.channel_type == 0
      feeds = Feedjira::Feed.fetch_and_parse [self.source]
      FeedHelper::Web.process_feeds(feeds)
    end
  end

  private

  def analyze_source
    if parse_link(source) =~ URI::regexp

      self.channel_type = 0
      if self.name.blank?
        self.name = FeedHelper::Spike.detect_title(source)
      end

      feed_url = FeedHelper::Spike.detect_feed(source)
      self.source = feed_url.first
    end
  end

  def parse_link(url)
    u=URI.parse(url)
    if (!u.scheme)
        url = "http://" + url
    end
    url
  end

end

