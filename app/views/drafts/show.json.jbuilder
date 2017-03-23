json.key_format! camelize: :lower
json.currentPick(@current_pick)
json.currentTeam(@current_team)
json.draftStatus(@league.draft_status.description)
json.league(@league.id)
json.leagueManagerId(@league.user_id)
json.picks(@picks) do |pick|
  json.id pick.id
  json.overallPick pick.overall_pick
  json.player pick.player.try(:name)
  json.round pick.round
  json.roundPick pick.round_pick
  json.teamId pick.team_id
end

json.players @players, :id, :name, :position, :team, :injury, :headline, :photo_url

json.positions(@positions) do |position|
  json.value position
  json.name position
end

json.teams(@teams)
