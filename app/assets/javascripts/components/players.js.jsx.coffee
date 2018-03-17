@Player = createReactClass
  render: ->
    player = @props.player
    playerNameCellContent =
      if @props.userCanSelectPlayers
        `<a href="" className="select" onClick={this.props.onSelect.bind(null, player.id)}>
          {player.name}
        </a>`
      else
        `<span>{player.name}</span>`
    icons =
      if player.injury?
        `<i
           className="injury material-icons red-text text-darken-4 tooltipped"
           data-tooltip={player.injury}
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

@PlayersIndex = createReactClass
  componentDidMount: -> $('.tooltipped').tooltip({delay: 100})
  componentDidUpdate: -> $('.tooltipped').tooltip({delay: 100})
  shouldComponentUpdate: (nextProps, nextState) ->
    @props.players isnt nextProps.players or @props.searchText isnt nextProps.searchText
  render: ->
    searchText = @props.searchText.trim().toLowerCase()
    filteredPlayers = _(@props.players).filter (player) ->
      player.name.trim().toLowerCase().match searchText
    displayedPlayers = filteredPlayers.slice(0, 100)

    players = displayedPlayers.map ((player, i) ->
      `<Player
        key={i}
        player={player}
        onSelect={this.props.selectPlayer}
        userCanSelectPlayers={this.props.userCanSelectPlayers}
      />`
    ).bind(@)

    truncationMessage =
      if filteredPlayers.length > displayedPlayers.length
        `<div id="truncation-message">
          Showing top 100 results. Please filter or search to see more.
        </div>`
      else
        null

    `<div>
      <table className="hoverable">
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
      </table>
      {truncationMessage}
    </div>`
