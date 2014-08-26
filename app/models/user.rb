class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  #Only Digits, Numbers, dash and underscore allowed, dash/underscore only
  #allowed within a name cannot start or end whith those chars, also only 1 can
  #be used at time
  VALID_USERNAME_REGEX = /\A[A-Za-z0-9]+([-_][A-Za-z0-9]+)*\z/
  validates :username, presence: true, :uniqueness => {:case_sensitive => false},
            length: { maximum: 20 }, format: { with: VALID_USERNAME_REGEX }

  has_many :myrakes
  has_many :authentications

  def import_fb
    hash = get_fb_likes
    webdev = false
    hash.each do |name,data|
      case name.downcase
      when "ruby on rails" then webdev = true
      when "javascript" then webdev = true
      when "nodejs" then webdev = true
      end
    end

    if webdev == true
      master_rake = MasterRake.find_by(name: "Web Development")
      Myrake.find_or_create_by!(name: master_rake.name, master_rake_id: master_rake.id, user_id: id)
    end
  end

  def get_fb_likes
    fb_token = get_fb_token
    unless fb_token.nil?
      FeedHelper::Facebook.new(fb_token).get_likes
    end
  end

  def get_fb_news_feed
    fb_token = get_fb_token
    unless fb_token.nil?
      FeedHelper::Facebook.new(fb_token).process_news_feed
    end
  end

  def get_fb_news_feed_json
    fb_token = get_fb_token
    unless fb_token.nil?
      FeedHelper::Facebook.new(fb_token).get_news_feed
    end
  end

  def get_fb_token
    fb_provider = authentications.find_by(provider: "facebook")
    unless fb_provider.nil?
      fb_provider.oauth_token
    end
  end

  def get_tw_token
    tw_provider = authentications.find_by(provider: "twitter")
    unless tw_provider.nil?
      return tw_provider.oauth_token, tw_provider.oauth_secret
    end
  end


  def get_tw_news_feed
    tw_token = get_tw_token
    unless tw_token.nil?
      FeedHelper::RTwitter.new(tw_token).process_news_feed
    end
  end

  def get_snapshot_count
    get_snapshot_count = 0
    self.myrakes.each do |r|
      get_snapshot_count += r.snapshot_count
    end
    return get_snapshot_count
  end

  def get_notifications
    #ids = []
    #self.myrakes.each do |rake|
    #  ids << Leaflet.where(channel_id: rake.master_rake.get_notification.id).pluck(:id)
    #end
    #Leaflet.find(ids.flatten!) unless ids.empty?
  end

  def get_created_leaflets
    rake_ids = self.myrakes.pluck(:id)
    channel_ids = Channel.where("channels.source IN (?)", rake_ids.map(&:to_s)).pluck(:id)
    Leaflet.where("leaflets.channel_id IN (?)", channel_ids.map(&:to_s)).uniq
  end

  def get_created_leaflets_count
    get_created_leaflets.count
  end

  def get_save_count
    self.myrakes.map{ |rake| rake.heap.leaflets.count }.sum
  end

  def get_saves
    leaflets = self.myrakes.map{ |rake| rake.heap.leaflets }.flatten
    leaflets.inject(Hash.new(0)) { |total, e| total[e.channel.name] += 1 ;total }
  end

  def get_save_score
    leaflets = get_created_leaflets
    leaflets.map(&:save_count).sum - leaflets.count
  end

end
