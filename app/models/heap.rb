class Heap < ActiveRecord::Base
  validates :rake_id, presence: true

  belongs_to :rake
end
