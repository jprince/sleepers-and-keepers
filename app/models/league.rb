class League < ActiveRecord::Base
  validates :name, presence: true
  validates :password, presence: true
  validates :rounds, presence: true
  validates :size, presence: true
  belongs_to :sport
  belongs_to :user
end
