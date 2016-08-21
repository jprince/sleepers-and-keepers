@pickDuration = 120
@DraftRoom = React.createClass
  clearSearch: ->
    @setState({ searchText: '' })
    @refs.playerSearch.value = '' if @refs.playerSearch?
  closeConfirmationModal: (e) ->
    e.preventDefault()
    @setState({ playerToBeDrafted: { id: undefined, name: undefined } })
    $('#confirm-modal').closeModal()
  componentDidMount: -> @setupSubscription()
  componentWillMount: ->
    @delayedSearchCallback = _.debounce(((e) -> @setState({ searchText: e.target.value })), 300)
  getInitialState: ->
    selectedPosition = getFirstOption(@props.positions)

    currentPick: @props.currentPick
    draftStatus: @props.draftStatus
    lastSelectedPlayer: {}
    picks: @props.picks
    players: @filterPlayersByPosition(selectedPosition)
    playerToBeDrafted: { id: undefined, name: undefined }
    searchText: ''
    selectedPosition: selectedPosition
    userIsLeagueManager: @props.currentTeam.userId is @props.leagueManagerId
    userIsOnTheClock: @props.currentTeam.id is @props.currentPick?.teamId
  filterPlayersByPosition: (selectedPosition, players = @props.players) ->
    if selectedPosition is 'ALL' then players else _(players).filter(position: selectedPosition)
  openSelectPlayerModal: (selectedPlayerId, e) ->
    e.preventDefault()
    playerName = getPlayerName(_(@state.players).findWhere({id: selectedPlayerId}))
    @setState({ playerToBeDrafted: { id: selectedPlayerId, name: playerName }})
    $('#confirm-modal').openModal()
  refreshData: (updatedData) ->
    return unless updatedData?
    if updatedData.isUndo
      @state.players.push updatedData.lastSelectedPlayer
      updatedPlayers = _(@state.players).sortBy (player) -> player.lastName
    else if updatedData.lastSelectedPlayer?
      selectedPlayer = updatedData.lastSelectedPlayer
      updatedPlayers = _(@state.players).reject (player) -> player.id is selectedPlayer.id
      pickInfo = "Pick #{@state.currentPick.roundPick} (#{@state.currentPick.overallPick} overall)"
      selectedPlayerInfo =
        draftPosition: "Round #{@state.currentPick.round} | #{pickInfo}"
        info: "#{selectedPlayer.team} #{selectedPlayer.position}"
        name: "#{selectedPlayer.firstName} #{selectedPlayer.lastName}"
        photo: selectedPlayer.photoUrl
        team: _(@props.teams).findWhere(id: @state.currentPick.teamId).name
      @setState({ lastSelectedPlayer: selectedPlayerInfo })
      playerModalTimeout = setTimeout((-> $('#player-modal').closeModal()), 12000)
      $('#player-modal').openModal(complete: -> clearTimeout(playerModalTimeout))
    @setState({ draftStatus: updatedData.draftStatus })
    @setState({ picks: @updatePicks(updatedData.lastSelectedPlayer, updatedData.isUndo) })
    @setState({ players: @filterPlayersByPosition(@state.selectedPosition, updatedPlayers) })
    @setState({ playerToBeDrafted: { id: undefined, name: undefined } })
    @setState({ currentPick: updatedData.currentPick })
    @setState({ userIsOnTheClock: @props.currentTeam.id is updatedData.currentPick?.teamId })
  selectPlayer: (e) ->
    e.preventDefault()

    url = "/leagues/#{@props.league}/draft_picks"
    $.ajax
      dataType: 'json'
      data:
        pick:
          pickId: @state.currentPick.id
          playerId: @state.playerToBeDrafted.id
      method: 'POST'
      url: url
      success: ((updatedData) =>
        @clearSearch()
        $('#confirm-modal').closeModal()
        @refreshData(updatedData)
      ).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  selectPosition: (selectedPosition) ->
    @setState(players: @filterPlayersByPosition(selectedPosition))
    @setState(selectedPosition: selectedPosition)
  setupSubscription: ->
    App.cable.subscriptions.create { channel: 'DraftRoomChannel', league_id: @props.league },
      connected: -> # Called when the subscription is ready for use on the server
      disconnected: -> # Called when the subscription has been terminated by the server
      received: (response) ->
        @refreshData(response.data)
      refreshData: @refreshData
  undoLastPick: ->
    url = "/leagues/#{@props.league}/draft_picks"
    $.ajax
      dataType: 'json'
      method: 'DELETE'
      url: url
      success: ((updatedData) => @refreshData(updatedData)).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  updatePicks: (lastSelectedPlayer, isUndo) ->
    return unless lastSelectedPlayer?
    currentPick = @state.currentPick.id
    picks = @state.picks
    picks.forEach (pick) ->
      if pick.id is currentPick
        pick.player =
          if isUndo
            undefined
          else
            "#{lastSelectedPlayer.lastName}, #{lastSelectedPlayer.firstName}"
    picks
  updateSearchText: (e) ->
    e.persist()
    @delayedSearchCallback(e)

  render: ->
    if @state.draftStatus is 'Complete' or @state.currentPick is undefined
      `<div className="row">
        <div className="col s12 center-align">
          <h4>Draft Complete!</h4>
          <h5><a href="./draft_results">View Results</a></h5>
        </div>
      </div>`
    else
      `<div>
        <div id="player-modal" className="modal">
          <div className="modal-content">
            <div className="row">
              <span id="player-photo" className="col s4">
                <img src={this.state.lastSelectedPlayer.photo} />
                <h4>{this.state.lastSelectedPlayer.info}</h4>
              </span>
              <span id="pick-info" className="col s8">
                <h2>{this.state.lastSelectedPlayer.name}</h2>
                <h4>{this.state.lastSelectedPlayer.team}</h4>
                <h5>{this.state.lastSelectedPlayer.draftPosition}</h5>
              </span>
            </div>
          </div>
        </div>
        <div id="confirm-modal" className="modal">
          <div className="modal-content">
            Are you sure you want to draft {this.state.playerToBeDrafted.name}?
          </div>
          <div className="modal-footer">
            <a
              href="#!"
              className="modal-action waves-effect waves-green btn-flat"
              onClick={this.selectPlayer}>
            Yes</a>
            <a
              href="#!"
              className="modal-action waves-effect waves-red btn-flat"
              onClick={this.closeConfirmationModal}>
            No</a>
          </div>
        </div>
        <DraftTicker
          currentPick={this.state.currentPick}
          picks={this.state.picks}
          showAdminButtons={this.state.userIsLeagueManager}
          teams={this.props.teams}
          undoLastPick={this.undoLastPick}
          userIsOnTheClock={this.state.userIsOnTheClock}
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
        <input
          id="player-search"
          onChange={this.updateSearchText}
          placeholder="Player name"
          ref="playerSearch"
          type="text"
        />
        <PlayersIndex
          players={this.state.players}
          searchText={this.state.searchText}
          selectPlayer={this.openSelectPlayerModal}
          userCanSelectPlayers={this.state.userIsLeagueManager || this.state.userIsOnTheClock}
        />
       </div>`

@DraftTicker = React.createClass
  componentWillReceiveProps: (newProps) -> @setState({ currentPickId: newProps.currentPick?.id })
  getInitialState: ->
    currentPickId: @props.currentPick?.id
    timerPaused: false
  getTeamNameById: (id) -> _(@props.teams).findWhere(id: id)?.name
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
          <PickTimer
            currentPickId={this.state.currentPickId}
            isPaused={this.state.timerPaused}
            userIsOnTheClock={this.props.userIsOnTheClock}
          />
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
    if @state.secondsRemaining in [1..30]
      classes = if @state.secondsRemaining <= 10 then 'red darken-2' else 'orange darken-1'
      Materialize.toast(@state.secondsRemaining, 1000, classes)
    else if @state.secondsRemaining <= 0
      if @props.userIsOnTheClock
        Materialize.toast("Time's up, bitch! Pick somebody.", 10000, 'red darken-2')
      @setState({ timeExpired: true })
      clearInterval(@interval)
  runTimer: -> @interval = setInterval(@tick, 1000)
  render: ->
    `<div>Time remaining: <span id="time-remaining">{this.state.secondsRemaining}</span></div>`
