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
      success: ((updatedData) => @refreshData(updatedData)).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  selectPosition: (selectedPosition) ->
    @setState(players: @filterPlayersByPosition(selectedPosition))
    @setState(selectedPosition: selectedPosition)
  undoLastPick: ->
    url = "/leagues/#{@props.league}/draft_picks"
    $.ajax
      dataType: 'json'
      method: 'PUT'
      url: url
      success: ((updatedData) => @refreshData(updatedData)).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  render: ->
    `<div>
      <DraftTicker
        currentPick={this.state.currentPick}
        picks={this.state.picks}
        showUndoButton={this.props.userIsLeagueManager}
        teams={this.props.teams}
        undoLastPick={this.undoLastPick}
      />
      <div className="clear-floats"></div>
      <div className="divider"></div>
      <div>
        <Select
          class="position-select"
          label="Position"
          options={this.props.positions}
          onChange={this.selectPosition}
        />
      </div>
      <PlayersIndex players={this.state.players} selectPlayer={this.selectPlayer}/>
     </div>`

@DraftTicker = React.createClass
  componentWillReceiveProps: (newProps) -> @setState({ currentPickId: newProps.currentPick.id })
  getInitialState: -> currentPickId: @props.currentPick?.id
  getTeamNameById: (id) -> _(@props.teams).findWhere(id: id).name
  render: ->
    indexOfCurrentPick = (@props.picks.map (pick) -> pick.id).indexOf(@state.currentPickId)
    startingPick = _([0, indexOfCurrentPick - 8]).max()
    recentPicksArray = @props.picks.slice(startingPick, indexOfCurrentPick)
    upcomingPicksArray = @props.picks.slice(indexOfCurrentPick + 1, indexOfCurrentPick + 9)
    recentPicks = recentPicksArray.map ((pick, i) ->
      `<Pick key={i} pick={pick} showPlayer="true" teamName={this.getTeamNameById(pick.teamId)} />`
    ).bind(@)
    upcomingPicks = upcomingPicksArray.map ((pick, i) ->
      `<Pick key={i} pick={pick} teamName={this.getTeamNameById(pick.teamId)} />`
    ).bind(@)
    undoButton =
      if @props.showUndoButton
        `<div>
          <button
            className="btn btn-icon waves-effect waves-light"
            id="undo-last-pick"
            onClick={this.props.undoLastPick}
            type="button"
          >
            <i className="material-icons">undo</i>
          </button>
        </div>`
      else
        null

    `<div id="draft-ticker">
      <div className="row recent-picks">{recentPicks}</div>
      <div className="row clear-floats"></div>
      <div id="current-pick" className="row valign-wrapper">
        <div className="col s4 offset-s4 center-align valign">
          <div>Round {this.props.currentPick.round} | Pick {this.props.currentPick.roundPick}</div>
          <div>On the clock: {this.getTeamNameById(this.props.currentPick.teamId)}</div>
          <div>Time remaining: 2:00</div>
        </div>
        <div className="col s1 valign">{undoButton}</div>
        <div className="col s3"></div>
      </div>
      <div className="clear-floats"></div>
      <div className="row upcoming-picks">{upcomingPicks}</div>
    </div>`
