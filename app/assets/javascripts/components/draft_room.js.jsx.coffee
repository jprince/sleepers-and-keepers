@DraftRoom = React.createClass
  getFirstUnusedPick: (picks) -> _(picks).filter(player: null)[0]
  getInitialState: ->
    picks = @props.picks
    selectedPosition = getFirstOption(@props.positions)

    currentPick: @getFirstUnusedPick(picks)
    picks: picks
    players: @filterPlayersByPosition(selectedPosition)
    selectedPosition: selectedPosition
  filterPlayersByPosition: (selectedPosition, players = @props.players) ->
    if selectedPosition is 'ALL' then players else _(players).filter(position: selectedPosition)
  refreshData: (updatedData) ->
    @setState({ currentPick: @getFirstUnusedPick(updatedData.picks) })
    @setState({ picks: updatedData.picks })
    @setState({ players: @filterPlayersByPosition(@state.selectedPosition, updatedData.players) })
  selectPlayer: (selectedPlayerId, e) ->
    e.preventDefault()
    player = _(@state.players).findWhere({id: selectedPlayerId})
    playerName = getPlayerName(player)
    confirmedResponse = confirm("Are you sure you want to draft #{playerName}")
    return unless confirmedResponse
    url = "/leagues/#{@props.league}/draft_picks"
    $.ajax
      dataType: 'json'
      data:
        pick:
          pickId: @state.currentPick.id
          playerId: selectedPlayerId
      method: 'POST'
      url: url
      success: (updatedData, status) => @refreshData(updatedData)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  selectPosition: (selectedPosition) ->
    @setState(players: @filterPlayersByPosition(selectedPosition))
    @setState(selectedPosition: selectedPosition)
  render: ->
    `<div>
      <DraftTicker
        currentPick={this.state.currentPick}
        picks={this.state.picks}
        teams={this.props.teams}
      />
      <div className="clear"></div>
      <hr />
      <div>
        Position:
        <Select
          class="position-select"
          options={this.props.positions}
          onChange={this.selectPosition}
        />
      </div>
      <hr />
      <PlayersIndex players={this.state.players} selectPlayer={this.selectPlayer}/>
     </div>`

@DraftTicker = React.createClass
  componentWillReceiveProps: (newProps) -> @setState({ currentPickId: newProps.currentPick.id })
  getInitialState: -> currentPickId: @props.currentPick?.id
  getTeamNameById: (id) -> _(@props.teams).findWhere(id: id).name
  render: ->
    indexOfCurrentPick = (@props.picks.map (pick) -> pick.id).indexOf(@state.currentPickId)
    startingPick = _([0, indexOfCurrentPick - 3]).max()
    endingPick = _([@props.picks.length, startingPick + 7]).min()
    recentPicks = @props.picks.slice(startingPick, endingPick)
    picks = recentPicks.map ((pick, i) ->
      teamName = @getTeamNameById(pick.teamId)
      `<Pick currentPickId={this.state.currentPickId} key={i} pick={pick} teamName={teamName} />`
    ).bind(@)

    `<div className="draft-ticker">
      <div id="on-the-clock">
        On the clock: {this.getTeamNameById(this.props.currentPick.teamId)}
      </div>
      {picks}
    </div>`
