json.league(@league.id)

json.picks(@available_picks) do |pick|
  json.value pick.id
  json.name "Rd: #{pick.round}, Pick: #{pick.round_pick} (#{pick.overall_pick} overall)"
  json.team pick.team_id
end

json.teams(@teams) do |team|
  json.value team.id
  json.name team.name
end
