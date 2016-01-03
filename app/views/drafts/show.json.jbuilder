json.draftStatus(DraftStatus.find(@data[:league].draft_status_id).description)
json.league(@data[:league].id)
json.picks(@data[:picks]) do |pick|
  json.id pick.id
  json.overallPick pick.overall_pick
  json.player pick.player_first_name.blank? ? pick.player_last_name : "#{pick.player_last_name}, #{pick.player_first_name}"
  json.round pick.round
  json.roundPick pick.round_pick
  json.teamId pick.team_id
end

json.players(@data[:players]) do |player|
  json.extract! player, :first_name, :id, :last_name, :position, :team, :injury, :headline
end

json.positions(@data[:positions]) do |position|
  json.value position
  json.name position
end

json.teams(@data[:teams]) do |team|
  json.extract! team, :id, :name
end

json.userIsLeagueManager(current_user.id == @data[:league].user_id)
