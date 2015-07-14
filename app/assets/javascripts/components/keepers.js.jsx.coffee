getFirstOption = (options) -> if _(options).any() then options[0].value else null

@KeepersForm = React.createClass
  componentWillReceiveProps: (newProps) ->
    @setState({ selectedPick: getFirstOption(@getPicksForSelectedTeam(newProps.selectedTeam)) })
    @setState({ selectedPlayer: getFirstOption(@getPlayersForSelectedPosition()) })
  getInitialState: ->
    defaultPosition = getFirstOption(@props.positions)
    selectedPick: getFirstOption(@getPicksForSelectedTeam())
    selectedPosition: defaultPosition
    selectedPlayer: getFirstOption(@getPlayersForSelectedPosition(defaultPosition))
  getPicksForSelectedTeam: (selectedTeam) ->
    _(@props.picks).filter({team: (selectedTeam or @props.selectedTeam)})
  getPlayersForSelectedPosition: (position) ->
    _(@props.players).filter({position: (position or @state.selectedPosition)})
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
      success: (updatedData, status) => @props.afterSubmit(updatedData)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  selectPick: (selection) -> @setState({ selectedPick: selection })
  selectPlayer: (selection) -> @setState({ selectedPlayer: selection })
  selectPosition: (selection) ->
    @setState({ selectedPosition: selection })
    @selectPlayer(getFirstOption(@getPlayersForSelectedPosition(selection)))
  render: ->
    `<form onSubmit={this.handleSubmit}>
      <Select
        class="position-select"
        onChange={this.selectPosition}
        options={this.props.positions}
      />
      <Select
        class="player-select"
        onChange={this.selectPlayer}
        options={this.getPlayersForSelectedPosition()}
      />
      <Select
        class="pick-select"
        onChange={this.selectPick}
        options={this.getPicksForSelectedTeam()}
      />
      <input type="submit" value="Save" />
    </form>`

@KeeperList = React.createClass
  componentWillReceiveProps: (newProps) ->
    @setState({ selectedTeamKeepers: @getKeepersForTeam(newProps.keepers, newProps.selectedTeam) })
  getInitialState: ->
    selectedTeamKeepers: @getKeepersForTeam(@props.keepers, @props.selectedTeam)
  getKeepersForTeam: (keepers, selectedTeam) ->
    _(keepers).filter(team: parseInt(selectedTeam))
  handleKeeperRemove: (index, e) ->
    e.preventDefault()
    url = "/leagues/#{@props.league}/keepers"
    $.ajax
      dataType: 'json'
      method: 'DELETE'
      url: url + '?' + $.param({ 'pickId': @state.selectedTeamKeepers[index].pick_id })
      success: (updatedData, status) => @props.afterRemove(updatedData)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  render: ->
    keepers = @state.selectedTeamKeepers.map ((player, i) ->
      keeperText = "#{player.player_name} - #{player.pick}"
      `<li className="keeper" key={i}>
          {keeperText}
          <a className="remove" onClick={this.handleKeeperRemove.bind(this, i)}>X</a>
        </li>`
    ).bind(@)

    `<div>
      <ol>
       {keepers}
      </ol>
    </div>`

@KeeperPage = React.createClass
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
      <Select class="team-select" options={this.props.teams} onChange={this.selectTeam} />
      <hr />
      <KeepersForm
        afterSubmit={this.refreshData}
        league={this.props.league}
        picks={this.state.picks}
        players={this.state.players}
        positions={this.props.positions}
        selectedTeam={this.state.selectedTeam}
        teams={this.props.teams}
      />
      <hr />
      <KeeperList
        afterRemove={this.refreshData}
        keepers={this.state.keepers}
        league={this.props.league}
        selectedTeam={this.state.selectedTeam}
      />
     </div>`
