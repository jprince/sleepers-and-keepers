@Player = React.createClass
  render: ->
    player = @props.player
    playerName = getPlayerName(player)

    `<tr className="player">
      <td>
        <a href="" className="select" onClick={this.props.onSelect.bind(null, player.id)}>
          {playerName}
        </a>
      </td>
      <td>{player.position}</td>
      <td>{player.team}</td>
      <td>{player.injury}</td>
      <td>{player.headline}</td>
    </tr>`

@PlayersIndex = React.createClass
  render: ->
    players = @props.players.map ((player, i) ->
      `<Player key={i} player={player} onSelect={this.props.selectPlayer} />`
    ).bind(@)

    `<table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Position</th>
          <th>Team</th>
          <th>Injury</th>
          <th>News</th>
        </tr>
      </thead>
      <tbody>
        {players}
      </tbody>
    </table>`
