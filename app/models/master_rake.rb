class MasterRake < ActiveRecord::Base
  after_create :create_channel
  attr_accessor :feed_leaflets

  validates :name, presence: true, :uniqueness => {:case_sensitive => false}

  has_many :channels_master_rakes, dependent: :destroy
  has_many :channels, through: :channels_master_rakes, dependent: :destroy

  has_many :rakes
  has_one :category

  def add_channel(channel)
    self.channels_master_rakes.create(channel_id: channel.id)
    Leaflet.create!(channel_id: get_notification.id,
                    title: "New Channel available!",
                    content: "Channel " + channel.name + " has been added to " + name,
                    published_at: Time.new,
                    author: "Rakepage",
                    identifier: "channel_" + channel.id.to_s)
  end

  def remove_channel(channel)
    self.channels_master_rakes.find_by(channel_id: channel.id).destroy
  end

  def toggle_channel_display(channel, display)
    self.channels_master_rakes.find_by(channel_id: channel.id).update!(display: display)
  end

  def feed_leaflets
    Leaflet.where("channel_id IN (?)",
                      self.channels_master_rakes.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)

  end

  def existing_custom_rakes(user)
    Rake.where("user_id = ? AND master_rake_id = ?", user.id, self.id)
  end

  def get_notification
    Channel.find_by(source: "master_rake_" + self.id.to_s)
  end

  private

  def create_channel
    add_channel(Channel.create!(source: "master_rake_" + self.id.to_s, name: name + " Notification", channel_type: 5))
  end
end
