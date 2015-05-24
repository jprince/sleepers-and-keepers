class Team < ActiveRecord::Base
  validates :name, presence: true
  validates :short_name, presence: true, length: { maximum: 10 }

  belongs_to :league
  belongs_to :user
end