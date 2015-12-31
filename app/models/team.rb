class Team < ActiveRecord::Base
  validates :name, presence: true
  validates :short_name, presence: true, length: { maximum: 10 }

  belongs_to :league
  belongs_to :user
  has_many :picks, dependent: :delete_all
  has_many :players, through: :picks

  def self.bulk_update(data)
    Team.update(data.keys, data.to_h.values)
  end
end
