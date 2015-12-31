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

  def update_draft_status
    completed_draft_status_id = DraftStatus.find_by(description: 'Complete').id
    in_progress_draft_status_id = DraftStatus.find_by(description: 'In Progress').id
    not_started_draft_status_id = DraftStatus.find_by(description: 'Not Started').id
    picks_remaining = picks.where(player_id: nil).length

    if draft_status_id == not_started_draft_status_id ||
      (picks_remaining > 0 && draft_status_id == completed_draft_status_id)
      update_attributes(draft_status_id: in_progress_draft_status_id)
    elsif picks_remaining == 0 && draft_status_id == in_progress_draft_status_id
      update_attributes(draft_status_id: completed_draft_status_id)
    end
  end
end
