class Channel < ActiveRecord::Base
  require 'feed_helper'
  before_validation :analyze_source, on: :create
  attr_accessor :rake_id

  validates :source, presence: true, :uniqueness => {:case_sensitive => false}
  validates :name, presence: true
  validates :channel_type, presence: true
  # Enum values
  # 0: rss/atom
  # 1: facebook
  # 2: twitter
  # 3: rake
  # 4: reddit
  # 5: notifications

  has_many :channels_master_rakes, dependent: :destroy
  has_many :master_rakes, through: :channels_master_rakes, dependent: :destroy

  has_many :rake_channel_maps, dependent: :destroy
  has_many :rakes, through: :rake_channel_maps, dependent: :destroy

  scope :rss_feeds, -> { where(channel_type: 0) }
  scope :subreddits, -> { where(channel_type: 4) }


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
      FeedHelper::WebFeed.new(self.source).process_feeds
    when 4
      FeedHelper::Reddit.new(self.source).process_reddit
    end
    self.update_attribute(:last_pull_at, Time.now)
  end

  private

  def analyze_source
    begin
      if channel_type == 0 && parse_link(source) =~ URI::regexp
        feed_helper = FeedHelper::Scrapper.new(source)
        feeds = feed_helper.get_feed

        self.name = feed_helper.get_title
        self.source = feeds.shift

        feeds.each do |feed|
          begin
            Channel.create!(source: feed, channel_type: 0)
          rescue
          end
        end
      elsif channel_type == 4
        self.name = FeedHelper::Reddit.new(source).get_title
      end
    rescue FeedHelper::FeedNotFoundError
      self.errors.add(:base, "Could not retrieve data")
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

