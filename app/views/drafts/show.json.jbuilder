json.players(@players) do |player|
  json.extract! player, :first_name, :last_name, :position, :team, :injury, :headline
end
