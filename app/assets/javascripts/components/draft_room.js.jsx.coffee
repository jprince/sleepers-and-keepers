@DraftRoom = React.createClass
  getInitialState: ->
    picks = @props.picks
    selectedPosition = getFirstOption(@props.positions)

    currentPickId: _(picks).filter(player: null)[0]?.id
    picks: picks
    players: @getPlayersForPosition(selectedPosition)
    selectedPosition: selectedPosition
  getPlayersForPosition: (selectedPosition) ->
    if selectedPosition is 'ALL'
      @props.players
    else
      _(@props.players).filter(position: selectedPosition)
  selectPosition: (selectedPosition) ->
    @setState(players: @getPlayersForPosition(selectedPosition))
    @setState(selectedPosition: selectedPosition)
  render: ->
    `<div>
      <DraftTicker
        currentPickId={this.state.currentPickId}
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
      <PlayersIndex players={this.state.players}/>
     </div>`

@DraftTicker = React.createClass
  getInitialState: ->
    currentPick = _(@props.picks).findWhere(id: @props.currentPickId)

    currentTeamName: @getTeamNameById(currentPick.teamId)
  getTeamNameById: (id) -> _(@props.teams).findWhere(id: id).name
  render: ->
    indexOfCurrentPick = (@props.picks.map (pick) -> pick.id).indexOf(@props.currentPickId)
    startingPick = _([0, Math.abs(indexOfCurrentPick - 3)]).min()
    endingPick = _([@props.picks.length, startingPick + 6]).min()
    recentPicks = @props.picks.slice(startingPick, endingPick)
    picks = recentPicks.map ((pick, i) ->
      teamName = @getTeamNameById(pick.teamId)
      `<Pick currentPickId={this.props.currentPickId} key={i} pick={pick} teamName={teamName} />`
    ).bind(@)

    `<div className="draft-ticker">
      <div id="on-the-clock">On the clock: {this.state.currentTeamName}</div>
      {picks}
    </div>`
