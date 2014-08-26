class Filter < ActiveRecord::Base
  belongs_to :myrake

  validates :keyword, presence: true
  validates :filter_type, presence: true
  validates :myrake_id, presence: true

  # Enum values
  # 0: not defined yet
  # 1: including keyword
  # 2: excluding keyword

end
