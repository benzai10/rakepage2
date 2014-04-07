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

  def toggle_channel_display(channel, display)
    self.channels_master_rakes.find_by(channel_id: channel.id).update!(display: display)
  end

  def feed_leaflets
    feed_leaflets = Leaflet.where("channel_id IN (?)", 
                      self.channels_master_rakes.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)

  end

  def get_heap
    self.heap.leaflets
  end

  def existing_custom_rakes(user)
    Rake.where("user_id = ? AND master_rake_id = ?", user.id, self.id)
  end

end
