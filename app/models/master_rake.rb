class MasterRake < ActiveRecord::Base
  require 'feed_helper'
  after_create :create_channel
  attr_accessor :feed_leaflets
  attr_accessor :channel_type
  attr_accessor :source

  validates :name, presence: true, :uniqueness => {:case_sensitive => false}
  validates :wikipedia_url, presence: true, :uniqueness => {:case_sensitive => false}

  has_many :channels_master_rakes, dependent: :destroy
  has_many :channels, through: :channels_master_rakes, dependent: :destroy

  has_many :rakes
  #has_one :category

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
    if self.refreshed_at.nil? || self.refreshed_at < Time.now - 1200
      self.channels.each do |c|
        if c.last_pull_at < Time.now - 1200 
          begin
            c.pull_source
          rescue
          end
        end
      end
      self.update_attribute(:refreshed_at, Time.now)
    end
    Leaflet.where("channel_id IN (?)",
                      self.channels_master_rakes.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)

  end

  def existing_custom_rakes(user)
    Rake.where("user_id = ? AND master_rake_id = ?", user.id, self.id)
  end

  def get_notification
    Channel.find_by(source: "master_rake_" + self.id.to_s)
  end

  def check_wikipedia_url(url)
    begin
      feed_helper = FeedHelper::Wiki.new(url)
      feed_helper.valid_url?
    rescue
      false
    end
  end

  private

  def create_channel
    #add_channel(Channel.create!(source: "master_rake_" + self.id.to_s, name: name + " Notification", channel_type: 5))
  end

end
