class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #Only Digits, Numbers, dash and underscore allowed, dash/underscore only
  #allowed within a name cannot start or end whith those chars, also only 1 can
  #be used at time
  VALID_USERNAME_REGEX = /\A[A-Za-z0-9]+([-_][A-Za-z0-9]+)*\z/
  validates :username, presence: true, :uniqueness => {:case_sensitive => false},
            length: { maximum: 20 }, format: { with: VALID_USERNAME_REGEX }

  has_many :rakes
  has_many :authentications

end
