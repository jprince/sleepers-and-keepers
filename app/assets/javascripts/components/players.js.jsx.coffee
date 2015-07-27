@Player = React.createClass
  componentWillReceiveProps: (newProps) -> @setState({ userIsPicking: newProps.userIsPicking })
  getInitialState: -> userIsPicking: @props.userIsPicking
  render: ->
    icons =
      if player.injury
        `<i
           className="injury material-icons red-text text-darken-4"
           title={player.injury}
         >
           add_box
         </i>`
      else
        null

    `<tr className="player">
      <td>
        <a href="" className="select" onClick={this.props.onSelect.bind(null, player.id)}>
          {playerName}
        </a>
        {icons}
      </td>
    `
    player = @props.player
    playerName = getPlayerName(player)
    playerNameCellContent =
      if @props.userIsPicking
        `<a href="" className="select" onClick={this.props.onSelect.bind(null, player.id)}>
          {playerName}
        </a>`
      else
        `<span>{playerName}</span>`

    `<tr className="player">
      <td>{playerNameCellContent}</td>
      <td>{player.position}</td>
      <td>{player.team}</td>
      <td>{player.headline}</td>
    </tr>`

@PlayersIndex = React.createClass
  render: ->
    players = @props.players.map ((player, i) ->
      `<Player key={i} player={player} onSelect={this.props.selectPlayer} userIsPicking={this.props.userIsPicking} />`
    ).bind(@)

    `<table className="hoverable">
      <thead>
        <tr>
          <th>Name</th>
          <th>Position</th>
          <th>Team</th>
          <th>News</th>
        </tr>
      </thead>
      <tbody>
        {players}
      </tbody>
    </table>`
