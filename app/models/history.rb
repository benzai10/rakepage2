class History < ActiveRecord::Base
  belongs_to :user

  validates :history_str, length: { maximum: 300 }
  validates :history_text, length: { maximum: 600 }

  scope :liked, -> { where(history_code: "liked") }

end
