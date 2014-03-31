class MasterRake < ActiveRecord::Base
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

end
