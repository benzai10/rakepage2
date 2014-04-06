class MasterRake < ActiveRecord::Base
  attr_accessor :feed_leaflets

  validates :name, presence: true, :uniqueness => {:case_sensitive => false}

  has_many :channels_master_rakes, dependent: :destroy
  has_many :channels, through: :channels_master_rakes, dependent: :destroy

  has_many :rakes

  def add_channel(channel)
    self.channels_master_rakes.create(channel_id: channel.id)
  end

  def remove_channel(channel)
    self.channels_master_rakes.find_by(channel_id: channel.id).destroy
  end

  def feed_leaflets
    feed_leaflets = Leaflet.where("channel_id IN (?)", self.channels.all)
  end

  def get_heap
    self.heap.leaflets
  end

end
