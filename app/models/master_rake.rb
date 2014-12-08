class MasterRake < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  require 'feed_helper'
  after_create :create_channel
  attr_accessor :feed_leaflets
  attr_accessor :channel_type
  attr_accessor :source
  attr_accessor :history_code
  attr_accessor :admin

  validates :name, presence: true, :uniqueness => {:case_sensitive => false}
  validates :wikipedia_url, presence: true, :uniqueness => {:case_sensitive => false}, unless: :user_is_admin?
  # validates :wikipedia_url, presence: true, :uniqueness => {:case_sensitive => false}
  validates :category_id, presence: true

  has_many :channels_master_rakes, dependent: :destroy
  has_many :channels, through: :channels_master_rakes, dependent: :destroy

  has_many :myrakes
  has_many :master_heaps, dependent: :destroy
  #has_one :category

  scope :newly_added, -> { order(created_at: :desc).limit(99) }
  
  def add_channel(channel)
    self.channels_master_rakes.create(channel_id: channel.id)
  end

  def remove_channel(channel)
    self.channels_master_rakes.find_by(channel_id: channel.id).destroy
  end

  def toggle_channel_display(channel, display)
    self.channels_master_rakes.find_by(channel_id: channel.id).update!(display: display)
  end

  def feed_leaflets(refresh)
    if refresh == "yes"
      self.update_attributes(refreshed_at: Time.now)
      self.channels.each do |c|
        begin
          c.pull_source
        rescue
        end
      end
    end
    feed_leaflets = Leaflet.where("channel_id IN (?)",
                            self.channels_master_rakes.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)
  end

  def add_master_heap(leaflet_type_id)
    self.master_heaps.create(master_rake_id: self.id, leaflet_type_id: leaflet_type_id)
  end


  def existing_custom_rake(user)
    Myrake.where("user_id = ? AND master_rake_id = ?", user.id, self.id).first
  end

  def get_corakers
    data = []
    self.myrakes.each do |r|
      leaflets = Myrake.get_leaflets(r.id)
      user = User.where(id: r.user_id)
      if user.count > 0 && !leaflets.nil?
        data << [user.first.username, leaflets.count]
      end
    end
    data.sort_by{ |x| x[1] }.reverse!
  end

  def get_notification
    Channel.find_by(source: "master_rake_" + self.id.to_s)
  end

  def check_wikipedia_url(url)
    if !user_is_admin?
      begin
        feed_helper = FeedHelper::Wiki.new(url)
        feed_helper.valid_url?
      rescue
        false
      end
    else
      true
    end
  end

  private

  def user_is_admin?
    return User.find(self.created_by).admin?
  end

  def create_channel
    #add_channel(Channel.create!(source: "master_rake_" + self.id.to_s, name: name + " Notification", channel_type: 5))
  end

end
