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

  def begin_draft
    in_progress_draft_status = DraftStatus.find_by(description: 'In Progress')
    update_attributes(draft_status_id: in_progress_draft_status.id)
  end

  def complete_draft
    completed_draft_status = DraftStatus.find_by(description: 'Complete')
    update_attributes(draft_status_id: completed_draft_status.id)
  end

  def current_pick
    picks.order(:id).find_by(player_id: nil)
  end

  def draft_not_started?
    not_started_draft_status = DraftStatus.find_by(description: 'Not Started')

    draft_status == not_started_draft_status
  end

  def draft_state
    last_pick = current_pick.try(:previous)
    {
      current_pick: current_pick.try(:attributes),
      last_selected_player: last_pick ? Player.find(last_pick.player_id) : nil,
      draft_status: draft_status.description
    }
  end
end
