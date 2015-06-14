class Pick < ActiveRecord::Base
  validates :overall_pick, presence: true
  validates :round, presence: true
  validates :round_pick, presence: true

  belongs_to :player
  belongs_to :team
  has_one :league, through: :team

  def self.create_picks(league)
    remove_picks(league)
    draft_order = league.teams.sort_by(&:draft_pick)
    league.rounds.times do |round|
      league.size.times do |pick|
        create(
            league: league,
            overall_pick: (round * league.size) + (pick + 1),
            round: round + 1,
            round_pick: pick + 1,
            team: (round + 1).odd? ? draft_order[pick] : draft_order[-(pick + 1)]
          )
      end
    end
  end

  private

  def self.remove_picks(league)
    league.teams.each do |team|
      Team.find(team.id).picks.delete_all
    end
  end
end
