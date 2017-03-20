json.keepers(@keepers) do |keeper|
  pick = @league.picks.find_by(player_id: keeper.id)

  json.pick "Rd: #{pick.round}, Pick: #{pick.round_pick} (#{pick.overall_pick} overall)"
  json.pickId pick.id
  json.playerName keeper.name
  json.teamId pick.team_id
end

json.league(@league.id)

json.picks(@available_picks) do |pick|
  json.value pick.id
  json.name "Rd: #{pick.round}, Pick: #{pick.round_pick} (#{pick.overall_pick} overall)"
  json.teamId pick.team_id
end

json.players(@available_players) do |player|
  json.value player.id
  json.name player.name
  json.position player.position
end

json.positions(@positions) do |position|
  json.value position
  json.name position
end

json.teams(@teams) do |team|
  json.value team.id
  json.name team.name
end
