class Rake < ActiveRecord::Base
  after_create :create_heap
  attr_accessor :feed_leaflets

  validates :name, presence: true
  validates :master_rake_id, presence: true
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy
  has_one :heap, dependent: :destroy

  def self.create_page_rake(user,master_rake)
    hash = user.get_fb_likes
    hash.each do |name,urls|
      channels = []
      urls.each do |url|
        begin
          channels << Channel.create!(source: url)
        rescue FeedHelper::FeedNotFoundError => e
          p e.message
        rescue URI::InvalidURIError => e
          p e.message
        rescue ActiveRecord::RecordInvalid => e
          p e.message
        end
      end

      unless channels.empty?
        rake = Rake.create(name: name, master_rake_id: master_rake.id, user_id: user.id)
        channels.each do |channel|
          rake.add_channel(channel)
        end
      end
    end

  end

  def add_channel(channel)
    self.rake_channel_maps.create(channel_id: channel.id)
  end

  def remove_channel(channel)
    self.rake_channel_maps.find_by(channel_id: channel.id).destroy
  end

  def toggle_channel_display(channel, display)
    self.rake_channel_maps.find_by(channel_id: channel.id).update!(display: display)
  end

  def feed_leaflets
    feed_leaflets = Leaflet.where("channel_id IN (?)", 
                      self.rake_channel_maps.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)
  end

  def get_heap
    self.heap.leaflets
  end

  private

  def create_heap
    self.heap = Heap.create
  end

end
