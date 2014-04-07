class Channel < ActiveRecord::Base
  require 'feed_helper'
  before_validation :analyze_source, on: :create

  validates :source, presence: true, :uniqueness => {:case_sensitive => false}
  validates :name, presence: true
  validates :channel_type, presence: true
  # Enum values
  # 0: rss/atom
  # 1: facebook
  # 2: twitter
  # 3: rake
  # 4: reddit

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
    if channel_type == 0 && parse_link(source) =~ URI::regexp
      feed = FeedHelper::Spike.new(source)
      self.source = feed.get_feed.first
      self.name = feed.get_title
    end
  end

  def parse_link(url)
    uri = Addressable::URI.parse(url)
    if (!uri.scheme)
        url = "http://" + url
    end
    url
  end

end

