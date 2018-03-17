@KeepersForm = createReactClass
  componentWillReceiveProps: (newProps) ->
    updatedPlayers = @getPlayersForSelectedPosition(@state.selectedPosition)
    @setState({ players: updatedPlayers })
    @setState({ selectedPick: getFirstOption(@getPicksForSelectedTeam(newProps.selectedTeam)) })
    @setState({ selectedPlayer: getFirstOption(updatedPlayers) })
  getInitialState: ->
    defaultPosition = getFirstOption(@props.positions)
    players = @getPlayersForSelectedPosition(defaultPosition)

    players: players
    selectedPick: getFirstOption(@getPicksForSelectedTeam())
    selectedPosition: defaultPosition
    selectedPlayer: getFirstOption(players)
  getPicksForSelectedTeam: (selectedTeam) ->
    _(@props.picks).filter({teamId: (selectedTeam or @props.selectedTeam)})
  getPlayersForSelectedPosition: (selectedPosition) ->
    if selectedPosition is 'ALL'
      @props.players
    else
      _(@props.players).filter(position: selectedPosition)
  handleSubmit: (e) ->
    e.preventDefault()
    url = "/leagues/#{@props.league}/keepers"
    $.ajax
      dataType: 'json'
      data:
        pickId: @state.selectedPick
        playerId: @state.selectedPlayer
      method: 'POST'
      url: url
      success: ((updatedData) => @props.afterSubmit(updatedData)).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  selectPick: (selection) -> @setState({ selectedPick: selection })
  selectPlayer: (selection) -> @setState({ selectedPlayer: selection })
  selectPosition: (selection) ->
    updatedPlayers = @getPlayersForSelectedPosition(selection)
    @setState({ selectedPosition: selection })
    @setState({ players: updatedPlayers })
    @selectPlayer(getFirstOption(updatedPlayers))
  render: ->
    `<form onSubmit={this.handleSubmit}>
      <Select
        class="pick-select"
        label="Pick"
        onChange={this.selectPick}
        options={this.getPicksForSelectedTeam()}
      />
      <Select
        class="position-select"
        label="Position"
        onChange={this.selectPosition}
        options={this.props.positions}
      />
      <Select
        class="player-select"
        label="Player"
        onChange={this.selectPlayer}
        options={this.state.players}
      />
      <button className="btn waves-effect waves-light" type="submit">Save</button>
    </form>`

@KeeperList = createReactClass
  componentWillReceiveProps: (newProps) ->
    @setState({ selectedTeamKeepers: @getKeepersForTeam(newProps.keepers, newProps.selectedTeam) })
  getInitialState: ->
    selectedTeamKeepers: @getKeepersForTeam(@props.keepers, @props.selectedTeam)
  getKeepersForTeam: (keepers, selectedTeamId) ->
    _(keepers).filter(teamId: parseInt(selectedTeamId))
  handleKeeperRemove: (index, e) ->
    e.preventDefault()
    url = "/leagues/#{@props.league}/keepers"
    $.ajax
      dataType: 'json'
      method: 'DELETE'
      url: url + '?' + $.param({ 'pickId': @state.selectedTeamKeepers[index].pickId })
      success: ((updatedData) => @props.afterRemove(updatedData)).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  render: ->
    keepers = @state.selectedTeamKeepers.map ((player, i) ->
      keeperText = "#{player.playerName} - #{player.pick}"
      `<li className="keeper" key={i}>
          {keeperText}
          <i
            className="remove material-icons red-text text-darken-4"
            onClick={this.handleKeeperRemove.bind(this, i)}
          >
            remove_circle_outline
          </i>
        </li>`
    ).bind(@)

    `<div>
      <ol>
       {keepers}
      </ol>
    </div>`

@KeeperPage = createReactClass
  getInitialState: ->
    keepers: @props.keepers
    picks: @props.picks
    players: @props.players
    selectedTeam: getFirstOption(@props.teams)
  refreshData: (updatedData) ->
    @setState({ picks: updatedData.picks })
    @setState({ players: updatedData.players })
    @setState({ keepers: updatedData.keepers })
  selectTeam: (teamID) -> @setState({ selectedTeam: parseInt(teamID) })
  render: ->
    `<div>
      <Select
        class="team-select"
        label="Team"
        onChange={this.selectTeam}
        options={this.props.teams}
      />
      <KeepersForm
        afterSubmit={this.refreshData}
        league={this.props.league}
        picks={this.state.picks}
        players={this.state.players}
        positions={this.props.positions}
        selectedTeam={this.state.selectedTeam}
        teams={this.props.teams}
      />
      <div className="divider"></div>
      <KeeperList
        afterRemove={this.refreshData}
        keepers={this.state.keepers}
        league={this.props.league}
        selectedTeam={this.state.selectedTeam}
      />
     </div>`
