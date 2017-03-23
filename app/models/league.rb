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
    update_attributes(draft_status: DraftStatus.find_by(description: 'In Progress'))
  end

  def complete_draft
    update_attributes(draft_status: DraftStatus.find_by(description: 'Complete'))
  end

  def current_pick
    picks.order(:id)
         .select(:id, :overall_pick, :round, :round_pick, :team_id)
         .find_by(player_id: nil)
  end

  def draft_not_started?
    draft_status == DraftStatus.find_by(description: 'Not Started')
  end

  def draft_state
    last_pick = current_pick.try(:previous)
    {
      current_pick: current_pick.try(:attributes),
      last_selected_player: last_pick ? player_info(last_pick.player_id) : nil,
      league_id: id,
      draft_status: draft_status.description
    }
  end

  def undrafted_players
    drafted_player_ids = picks.where.not(player_id: nil).pluck(:player_id)
    sport.players.where.not(id: drafted_player_ids)
  end

  private

  def player_info(player_id)
    player =
      Player.select(:id, :first_name, :last_name, :position, :team, :injury, :headline, :photo_url)
            .find(player_id)
    player.attributes.merge('name' => player.name)
  end
end
