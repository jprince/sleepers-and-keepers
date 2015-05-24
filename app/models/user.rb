class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, format: {
    with: /@/,
    message: 'Invalid email address',
    on: :create
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
  has_many :teams
end
