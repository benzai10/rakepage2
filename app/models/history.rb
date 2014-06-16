class History < ActiveRecord::Base
  belongs_to :user

  scope :liked, -> { where(history_code: "liked") }

end
