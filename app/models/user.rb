class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #Only Digits, Numbers, dash and underscore allowed, dash/underscore only
  #allowed within a name cannot start or end whith those chars, also only 1 can
  #be used at time
  VALID_USERNAME_REGEX = /\A[A-Za-z0-9]+([-_][A-Za-z0-9]+)*\z/
  validates :username, presence: true, :uniqueness => {:case_sensitive => false},
            length: { maximum: 20 }, format: { with: VALID_USERNAME_REGEX }

  has_many :rakes
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
      Rake.find_or_create_by!(name: master_rake.name, master_rake_id: master_rake.id, user_id: id)
    end
    #    hash.each do |name,data|
    #      begin
    #
    #        feed_channels = []
    #
    #        master_rake = MasterRake.find_or_create_by!(name: data[:category])
    #        rake = Rake.find_or_create_by!(name: data[:category], master_rake_id: master_rake.id, user_id: id)
    #        feed_channels << Channel.find_or_create_by!(source: data[:fb_link], channel_type: 1, name: name)
    #
    #        data[:url].each do |url|
    #          feeds = FeedHelper::Spike.new(url).get_feed
    #          feeds.each do |feed|
    #            feed_channels << Channel.find_or_create_by!(source: feed, channel_type: 0)
    #          end
    #        end
    #
    #        feed_channels.each do |channel|
    #          rake.add_channel(channel)
    #          master_rake.add_channel(channel)
    #        end
    #
    #      rescue FeedHelper::FeedNotFoundError => e
    #        p e.message
    #      rescue URI::InvalidURIError => e
    #        p e.message
    #      rescue ActiveRecord::RecordInvalid => e
    #        p e.message
    #      end
    #    end
  end

  def get_fb_likes
    fb_token = get_fb_token
    unless fb_token.nil?
      FeedHelper::Facebook.new.get_likes(fb_token)
    end
  end

  def get_fb_token
    fb_provider = authentications.find_by(provider: "facebook")
    unless fb_provider.nil?
      fb_provider.oauth_token
    end
  end

  def get_snapshot_count
    get_snapshot_count = 0
    self.rakes.each do |r|
      get_snapshot_count += r.snapshot_count
    end
    return get_snapshot_count
  end

end
