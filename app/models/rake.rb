class Rake < ActiveRecord::Base
  after_create :create_heap, :create_channel

  validates :name, presence: true
  validates :master_rake_id, presence: true
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy
  has_one :heap, dependent: :destroy

  def add_channel(channel)
    self.rake_channel_maps.create(channel_id: channel.id)
  end

  def remove_channel(channel)
    self.rake_channel_maps.find_by(channel_id: channel.id).destroy
  end

  private

  def create_heap
    self.heap = Heap.create
  end

  def create_channel
    add_channel(Channel.create!(source: id.to_s, name: name, channel_type: 3))
  end

end
