class Rake < ActiveRecord::Base
  after_create :create_heap

  validates :name, presence: true
  validates :master_rake_id, presence: true
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy

  has_one :heap, dependent: :destroy

  private

  def create_heap
    self.heap = Heap.create
  end

end
