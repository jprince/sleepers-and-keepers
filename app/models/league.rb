class League < ActiveRecord::Base
  validates :draft_status_id, presence: true
  validates :name, presence: true
  validates :password, presence: true
  validates :rounds, presence: true
  validates :size, presence: true

  belongs_to :draft_status
  belongs_to :sport
  belongs_to :user
  has_many :picks, through: :teams
  has_many :teams, dependent: :delete_all
end
