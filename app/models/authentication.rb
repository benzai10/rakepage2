class Authentication < ActiveRecord::Base
  after_create :create_channel, :create_rake
  before_destroy :delete_rake
  belongs_to :user

  def self.from_omniauth(user, auth)
    where(auth.slice(:provider, :uid)).first_or_create do |authentication|
      authentication.user = user
      authentication.provider = auth.provider
      authentication.uid = auth.uid
      authentication.name = auth.info.name
      authentication.oauth_token = auth.credentials.token
      authentication.oauth_secret = auth.credentials.secret
      authentication.oauth_expires_at = set_oauth_expire(auth)
      authentication.save!
    end
  end

  private

  def self.set_oauth_expire(auth)
      if auth.credentials.expires_at.nil?
        return Time.now + 20.years
      end
      Time.at(auth.credentials.expires_at)
  end

  def create_channel
    Channel.create!(source: uid.to_s, name: provider, channel_type: channel_type)
  end

  def delete_channel
    Channel.find_by!(source: uid.to_s).destroy
  end

  def create_rake
    rake = Rake.create!(name: provider, user_id: user.id, master_rake_id: MasterRake.find_by(name: provider.humanize + " Import").id)
    rake.add_channel(Channel.find_by(source: uid.to_s))
  end

  def delete_rake
    RakeChannelMap.find_by(channel_id: Channel.find_by!(source: uid.to_s)).rake.destroy
    delete_channel
  end

  def channel_type
    case provider
    when "facebook"
      return 1
    when "twitter"
      return 2
    end
  end

end
