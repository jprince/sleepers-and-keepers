@pickDuration = 120
@DraftRoom = React.createClass
  getFirstUnusedPick: (picks) -> _(picks).filter(player: null)[0]
  getInitialState: ->
    picks = @props.picks
    currentPick = @getFirstUnusedPick(picks)
    selectedPosition = getFirstOption(@props.positions)

    currentPick: currentPick
    draftComplete: @props.draftStatus is 'Complete' or currentPick is undefined
    picks: picks
    players: @filterPlayersByPosition(selectedPosition)
    selectedPosition: selectedPosition
    userIsPicking: @props.currentTeamId is currentPick?.teamId
  filterPlayersByPosition: (selectedPosition, players = @props.players) ->
    if selectedPosition is 'ALL' then players else _(players).filter(position: selectedPosition)
  refreshData: (updatedData) ->
    currentPick = @getFirstUnusedPick(updatedData.picks)

    @setState({ currentPick: currentPick })
    @setState({ draftComplete: updatedData.draftStatus is 'Complete' or currentPick is undefined })
    @setState({ picks: updatedData.picks })
    @setState({ players: @filterPlayersByPosition(@state.selectedPosition, updatedData.players) })
    @setState({ userIsPicking: @props.currentTeamId is currentPick.teamId })
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
      success: ((updatedData) =>
        @refreshData(updatedData)
        $(document).scrollTop( $("#draft-ticker").offset().top )
      ).bind(@)
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
    if @state.draftComplete
      `<div className="row">
        <div className="col s12 center-align">
          <h4>Draft Complete!</h4>
          <h5><a href="./draft_results">View Results</a></h5>
        </div>
      </div>`
    else
      `<div>
        <DraftTicker
          currentPick={this.state.currentPick}
          picks={this.state.picks}
          showAdminButtons={this.props.userIsLeagueManager}
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
        <PlayersIndex
          players={this.state.players}
          selectPlayer={this.selectPlayer}
          userIsPicking={this.state.userIsPicking}
        />
      </div>`

@DraftTicker = React.createClass
  componentWillReceiveProps: (newProps) -> @setState({ currentPickId: newProps.currentPick.id })
  getInitialState: ->
    currentPickId: @props.currentPick?.id
    timerPaused: false
  getTeamNameById: (id) -> _(@props.teams).findWhere(id: id).name
  togglePause: -> @setState({ timerPaused: not @state.timerPaused })
  render: ->
    indexOfCurrentPick = (@props.picks.map (pick) -> pick.id).indexOf(@state.currentPickId)
    startingPick = _([0, indexOfCurrentPick - 8]).max()
    recentPicksArray = @props.picks.slice(startingPick, indexOfCurrentPick)
    upcomingPicksArray = @props.picks.slice(indexOfCurrentPick + 1, indexOfCurrentPick + 9)
    recentPicks = recentPicksArray.map ((pick, i) ->
      `<Pick key={i} pick={pick} teamName={this.getTeamNameById(pick.teamId)} />`
    ).bind(@)
    upcomingPicks = upcomingPicksArray.map ((pick, i) ->
      `<Pick key={i} pick={pick} teamName={this.getTeamNameById(pick.teamId)} />`
    ).bind(@)

    pausePlayIcon =
      if @state.timerPaused
        `<i className="material-icons">play_arrow</i>`
      else
        `<i className="material-icons">pause</i>`

    adminButtons =
      if @props.showAdminButtons
        `<div>
          <button
            className="btn btn-icon waves-effect waves-light"
            id="toggle-pause-pick-timer"
            onClick={this.togglePause}
            type="button"
          >
            {pausePlayIcon}
          </button>

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
          <PickTimer currentPickId={this.state.currentPickId} isPaused={this.state.timerPaused} />
        </div>
        <div className="col s2 valign">{adminButtons}</div>
        <div className="col s2 valign"></div>
      </div>
      <div className="clear-floats"></div>
      <div className="row upcoming-picks">{upcomingPicks}</div>
    </div>`

@PickTimer = React.createClass
  componentDidMount: -> @runTimer()
  componentWillReceiveProps: (newProps) ->
    if newProps.isPaused isnt @state.isPaused
      @pause()
    else
      if newProps.currentPickId isnt @state.currentPickId
        @setState({ currentPickId: newProps.currentPickId })
        @setState({ secondsRemaining: pickDuration })
        if @state.timeExpired
          @setState({ timeExpired: false })
          clearInterval(@interval)
          @runTimer()
  componentWillUnmount: -> clearInterval(@interval)
  getInitialState: ->
    currentPickId: undefined
    isPaused: false
    secondsRemaining: pickDuration
    timeExpired: false
  pause: ->
    if not @state.isPaused
      clearInterval(@interval)
    else
      @runTimer()

    @setState({ isPaused: not @state.isPaused })
  tick: ->
    @setState({ secondsRemaining: @state.secondsRemaining - 1 })
    if @state.secondsRemaining <= 0
      alert("Time's up, bitch. Pick somebody!")
      @setState({ timeExpired: true })
      clearInterval(@interval)
  runTimer: -> @interval = setInterval(@tick, 1000)
  render: ->
    `<div>Time remaining: <span id="time-remaining">{this.state.secondsRemaining}</span></div>`
