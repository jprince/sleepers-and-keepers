json.key_format! camelize: :lower
json.currentPick(@league.current_pick.try(:attributes).try(:camelize))
json.currentTeam(@league.teams.find_by(user_id: current_user.id).try(:attributes).try(:camelize))
json.draftStatus(DraftStatus.find(@league.draft_status_id).description)
json.league(@league.id)
json.leagueManagerId(@league.user_id)
json.picks(@picks) do |pick|
  json.id pick.id
  json.overallPick pick.overall_pick
  json.player pick.player_first_name.blank? ? pick.player_last_name : "#{pick.player_last_name}, #{pick.player_first_name}"
  json.round pick.round
  json.roundPick pick.round_pick
  json.teamId pick.team_id
end

json.players(@players) do |player|
  json.extract! player, :first_name, :id, :last_name, :position, :team, :injury, :headline
end

json.positions(@positions) do |position|
  json.value position
  json.name position
end

json.teams(@teams) do |team|
  json.extract! team, :id, :name
end
