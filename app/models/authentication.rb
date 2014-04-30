class Authentication < ActiveRecord::Base
  after_create :create_channel
  before_destroy :delete_channel
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

  def channel_type
    case provider
    when "facebook"
      return 1
    when "twitter"
      return 2
    end
  end

end
