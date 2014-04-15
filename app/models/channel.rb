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

  def count_subscribers
    RakeChannelMap.where(channel_id: id, display: true).count
  end

  def pull_source
    case self.channel_type

    when 0
      feeds = Feedjira::Feed.fetch_and_parse [self.source]
      FeedHelper::Web.process_feeds(feeds)
    when 4
      FeedHelper::Reddit.new(self.source).process_reddit
    end
  end

  private

  def analyze_source
    if channel_type == 0 && parse_link(source) =~ URI::regexp
      feed_helper = FeedHelper::Spike.new(source)
      feeds = feed_helper.get_feed

      self.name = feed_helper.get_title
      self.source = feeds.shift

      feeds.each do |feed|
        Channel.create!(source: feed, channel_type: 0)
      end
    elsif channel_type == 4
      self.name = FeedHelper::Reddit.new(source).get_title
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

