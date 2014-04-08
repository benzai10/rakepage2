class Rake < ActiveRecord::Base
  after_create :create_heap

  validates :name, presence: true
  validates :master_rake_id, presence: true
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy
  has_one :heap, dependent: :destroy

  def self.create_page_rake(user)
    hash = user.get_fb_likes
    hash.each do |name,data|
      begin
        feed_channels = []

        master_rake = MasterRake.find_or_create_by!(name: data[:category])
        rake = Rake.find_or_create_by!(name: data[:category], master_rake_id: master_rake.id, user_id: user.id)
        feed_channels << Channel.find_or_create_by!(source: data[:fb_link], channel_type: 1, name: name)

        data[:url].each do |url|
          feeds = FeedHelper::Spike.new(url).get_feed
          feeds.each do |feed|
            feed_channels << Channel.find_or_create_by!(source: feed, channel_type: 0)
          end
        end
        feed_channels.each do |channel|
          rake.add_channel(channel)
          master_rake.add_channel(channel)
        end

      rescue FeedHelper::FeedNotFoundError => e
        p e.message
      rescue URI::InvalidURIError => e
        p e.message
      rescue ActiveRecord::RecordInvalid => e
        p e.message
      end
    end
  end

  def add_channel(channel)
    self.rake_channel_maps.create(channel_id: channel.id)
  end

  def remove_channel(channel)
    self.rake_channel_maps.find_by(channel_id: channel.id).destroy
  end

  private

  def create_heap
    self.heap = Heap.create
  end

end
