@Player = React.createClass
  componentWillReceiveProps: (newProps) ->
    @setState({ userCanSelectPlayers: newProps.userCanSelectPlayers })
  getInitialState: -> userCanSelectPlayers: @props.userCanSelectPlayers
  render: ->
    player = @props.player
    playerName = getPlayerName(player)
    playerNameCellContent =
      if @state.userCanSelectPlayers
        `<a href="" className="select" onClick={this.props.onSelect.bind(null, player.id)}>
          {playerName}
        </a>`
      else
        `<span>{playerName}</span>`
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
      <td>{playerNameCellContent} {icons}</td>
      <td>{player.position}</td>
      <td>{player.team}</td>
      <td>{player.headline}</td>
    </tr>`

@PlayersIndex = React.createClass
  render: ->
    searchText = @props.searchText.trim().toLowerCase()
    filteredPlayers = _(@props.players).filter (player) ->
      getPlayerName(player).trim().toLowerCase().match searchText
    players = filteredPlayers.map ((player, i) ->
      `<Player
        key={i}
        player={player}
        onSelect={this.props.selectPlayer}
        userCanSelectPlayers={this.props.userCanSelectPlayers}
      />`
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
