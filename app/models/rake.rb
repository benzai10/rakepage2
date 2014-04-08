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
