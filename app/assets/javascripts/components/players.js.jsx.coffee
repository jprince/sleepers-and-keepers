@Player = React.createClass
  render: ->
    player = @props.player
    playerName =
      if player.first_name? then "#{ player.last_name}, #{player.first_name}" else player.last_name

    `<tr className="player">
      <td>{playerName}</td>
      <td>{player.position}</td>
      <td>{player.team}</td>
      <td>{player.injury}</td>
      <td>{player.headline}</td>
    </tr>`

@PlayersIndex = React.createClass
  render: ->
    players = @props.players.map (player, i) -> `<Player key={i} player={player} />`
    `<table>
      <tr>
        <th>Name</th>
        <th>Position</th>
        <th>Team</th>
        <th>Injury</th>
        <th>News</th>
      </tr>
      {players}
    </table>`
