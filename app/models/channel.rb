class Channel < ActiveRecord::Base
  validates :name, presence: true
  validates :channel_type, presence: true
  validates :source, presence: true

  has_many :channels_master_rakes, dependent: :destroy
  has_many :master_rakes, through: :channels_master_rakes, dependent: :destroy

  has_many :rake_channel_maps, dependent: :destroy
  has_many :rakes, through: :rake_channel_maps, dependent: :destroy
end

