class Channel < ActiveRecord::Base
  validates :name, presence: true
  validates :type, presence: true
  validates :source, presence: true

  has_many :rake_channel_maps, dependent: :destroy
  has_many :rakes, through: :rake_channel_maps, dependent: :destroy
end

