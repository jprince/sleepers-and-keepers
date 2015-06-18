getFirstOption = (options) ->
  if _(options).any() then options[0].value else null

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
  handleKeeperSubmit: (e) ->
    e.preventDefault()
    $.ajax
      url: @props.url
      dataType: 'json'
      type: 'POST'
      data:
        pick_id: @state.selectedPick
        player_id: @state.selectedPlayer
      success: (updatedData, status) =>
        @props.afterSubmit(updatedData)
      error: ((xhr, status, err) -> console.error @props.url, status, err.toString()).bind(@)
  selectPick: (selection) -> @setState({ selectedPick: selection })
  selectPlayer: (selection) -> @setState({ selectedPlayer: selection })
  selectPosition: (selection) ->
    @setState({ selectedPosition: selection })
    @selectPlayer(getFirstOption(@getPlayersForSelectedPosition(selection)))
  render: ->
    `<form onSubmit={this.handleKeeperSubmit}>
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
  render: ->
    filteredKeepers = _(@props.keepers).filter(team: parseInt(@props.selectedTeam))
    keepers = filteredKeepers.map (player, i) ->
      keeperText = "#{player.player_name} - #{player.pick}"
      `<li className="keeper" key={i}>{keeperText}</li>`

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
    @setState({ keepers: _(updatedData.keepers) })
  selectTeam: (teamID) -> @setState({ selectedTeam: parseInt(teamID) })
  render: ->
    `<div>
      <Select class="team-select" options={this.props.teams} onChange={this.selectTeam} />
      <hr />
      <KeepersForm
        afterSubmit={this.refreshData}
        picks={this.state.picks}
        players={this.state.players}
        positions={this.props.positions}
        selectedTeam={this.state.selectedTeam}
        teams={this.props.teams}
        url={"/leagues/" + this.props.league + "/keepers"} />
      <hr />
      <KeeperList keepers={this.state.keepers} selectedTeam={this.state.selectedTeam} />
     </div>`
