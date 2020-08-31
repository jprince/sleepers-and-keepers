class Pick < ActiveRecord::Base
  validates :overall_pick, presence: true
  validates :round, presence: true
  validates :round_pick, presence: true

  belongs_to :player, -> { with_deleted }, optional: true
  belongs_to :team
  has_one :league, through: :team

  def last_pick_of_draft?
    self.class.find_by('id > ?', id).nil?
  end

  def player
    Player.unscoped { super }
  end

  def previous
    self.class.where(keeper: false).where('id < ?', id).last
  end

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

  def self.execute_trade(params)
    params = params.require(:picks)

    team_one = Pick.find(params['team_one_picks'].first).team_id
    team_two = Pick.find(params['team_two_picks'].first).team_id

    params['team_one_picks'].each do |pick|
      pick = Pick.find(pick)
      pick.team_id = team_two
      pick.save
    end

    params['team_two_picks'].each do |pick|
      pick = Pick.find(pick)
      pick.team_id = team_one
      pick.save
    end
  end

  def self.remove_picks(league)
    league.teams.each do |team|
      Team.find(team.id).picks.delete_all
    end
  end
end
