class Sport < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :leagues
end
