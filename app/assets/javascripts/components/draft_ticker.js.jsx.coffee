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
