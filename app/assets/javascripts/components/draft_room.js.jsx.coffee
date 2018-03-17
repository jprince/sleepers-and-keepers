@DraftRoom = createReactClass
  closeConfirmationModal: (e) ->
    e.preventDefault()
    @setState(playerToBeDrafted: { id: undefined, name: undefined })
    $('#confirm-modal').modal('close')
  componentDidMount: ->
    @setupSubscription()
    $('#confirm-modal').modal()
    playerModalTimeout = setTimeout((-> $('#player-modal').modal('close')), 12000)
    $('#player-modal').modal(complete: -> clearTimeout(playerModalTimeout))
  componentWillMount: ->
    @delayedSearchCallback = _.debounce(((e) -> @setState(searchText: e.target.value)), 300)
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
    playerName = _(@state.players).findWhere(id: selectedPlayerId).name
    @setState(playerToBeDrafted: { id: selectedPlayerId, name: playerName })
    $('#confirm-modal').modal('open')
  refreshData: (updatedData) ->
    return unless updatedData?
    lastSelectedPlayer = updatedData.lastSelectedPlayer

    if updatedData.isUndo
      @state.players.push lastSelectedPlayer
      updatedPlayers = _(@state.players).sortBy (player) -> player.name
    else if updatedData.lastSelectedPlayer?
      updatedPlayers = _(@state.players).reject (player) -> player.id is lastSelectedPlayer.id
      pickInfo = "Pick #{@state.currentPick.roundPick} (#{@state.currentPick.overallPick} overall)"
      lastSelectedPlayer =
        draftPosition: "Round #{@state.currentPick.round} | #{pickInfo}"
        info: "#{lastSelectedPlayer.team} #{lastSelectedPlayer.position}"
        name: "#{lastSelectedPlayer.firstName} #{lastSelectedPlayer.lastName}"
        photo: lastSelectedPlayer.photoUrl
        team: _(@props.teams).findWhere(id: @state.currentPick.teamId).name
      $('#player-modal').modal('open')
    @setState(
      currentPick: updatedData.currentPick
      draftStatus: updatedData.draftStatus
      lastSelectedPlayer: lastSelectedPlayer
      picks: @updatePicks(updatedData.lastSelectedPlayer, updatedData.isUndo)
      players: @filterPlayersByPosition(@state.selectedPosition, updatedPlayers)
      playerToBeDrafted: { id: undefined, name: undefined }
      searchText: ''
      userIsOnTheClock: @props.currentTeam.id is updatedData.currentPick?.teamId
    )
    @refs.playerSearch.value = '' if @refs.playerSearch?
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
        $('#confirm-modal').modal('close')
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
            lastSelectedPlayer.name
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
