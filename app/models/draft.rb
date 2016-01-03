class Draft
  def self.state(league_id)
    league = League.find(league_id)
    picks = league.picks.joins('LEFT JOIN players ON picks.player_id = players.id').select(
      'picks.*, players.first_name as player_first_name, players.last_name as player_last_name'
    ).order(:id)
    league.update_draft_status

    {
      league: league,
      picks: picks,
      players: Player.undrafted(league).sort_by { |p| [p.last_name, p.first_name] },
      positions: Sport.get_positions(Sport.find(league.sport.id)),
      teams: league.teams.sort_by(&:draft_pick)
    }
  end
end
