class Channel < ActiveRecord::Base
  validates :name, presence: true
  validates :channel_type, presence: true
  validates :source, presence: true

  has_and_belongs_to_many :master_rakes
  has_many :rake_channel_maps, dependent: :destroy
  has_many :rakes, through: :rake_channel_maps, dependent: :destroy
end

