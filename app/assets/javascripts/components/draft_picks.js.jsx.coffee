@Pick = React.createClass
  render: ->
    pick = @props.pick
    player = if pick.player then "Player: #{pick.player}" else `<span>&nbsp;</span>`
    `<div className="pick-wrapper col s3">
      <div className="pick">
        Round {pick.round} | Pick {pick.roundPick} ({pick.overallPick} overall)<br/>
        Team: {this.props.teamName}<br/>
        {player}
      </div>
    </div>`

@TradePicksForm = React.createClass
  getAllTeamsExcept: (teamID) -> _(@props.teams).reject (team) -> team.value is teamID
  getInitialState: ->
    firstTeam = getFirstOption(@props.teams)
    secondTeam = getSecondOption(@props.teams)

    firstTeamSelectOptions: @getAllTeamsExcept(secondTeam)
    secondTeamSelectOptions: @getAllTeamsExcept(firstTeam)
    picks: @props.picks
    selectedTeamOne: firstTeam
    selectedTeamOnePicks: []
    selectedTeamTwo: secondTeam
    selectedTeamTwoPicks: []
  getPicksForSelectedTeam: (selectedTeamID) -> _(@state.picks).filter({ team: selectedTeamID })
  handleSubmit: (e) ->
    e.preventDefault()
    url = "/leagues/#{@props.league}/draft_picks"
    $.ajax
      dataType: 'json'
      data:
        picks:
          teamOnePicks: @state.selectedTeamOnePicks
          teamTwoPicks: @state.selectedTeamTwoPicks
      method: 'PUT'
      url: url
      success: ((updatedData) => @refreshData(updatedData)).bind(@)
      error: ((xhr, status, err) -> console.error url, status, err.toString()).bind(@)
  refreshData: (updatedData) ->
    @setState({ picks: updatedData.picks })
    @setState({ selectedTeamOnePicks: [] })
    @setState({ selectedTeamTwoPicks: [] })
    $('#team-one-pick-select option:selected').removeAttr('selected')
    $('#team-two-pick-select option:selected').removeAttr('selected')
  selectPickOne: (options) -> @setState({ selectedTeamOnePicks: getSelection(options) })
  selectPickTwo: (options) -> @setState({ selectedTeamTwoPicks: getSelection(options) })
  selectTeamOne: (teamID) ->
    @setState({ selectedTeamOne: parseInt(teamID) })
    @setState({ secondTeamSelectOptions: @getAllTeamsExcept(parseInt(teamID)) })
    @setState({ selectedTeamOnePicks: [] })
    $('#team-one-pick-select option:selected').removeAttr('selected')
  selectTeamTwo: (teamID) ->
    @setState({ selectedTeamTwo: parseInt(teamID) })
    @setState({ firstTeamSelectOptions: @getAllTeamsExcept(parseInt(teamID)) })
    @setState({ selectedTeamTwoPicks: [] })
    $('#team-two-pick-select option:selected').removeAttr('selected')
  render: ->
    `<form onSubmit={this.handleSubmit}>
      <div className="row">
        <div className="col s6">
          <Select
            class="team-select"
            id="team-one-select"
            label="Team"
            onChange={this.selectTeamOne}
            options={this.state.firstTeamSelectOptions}
            preSelectedValue={this.state.selectedTeamOne}
          />
          <Select
            class="pick-select"
            id="team-one-pick-select"
            label="Pick"
            multiple="true"
            onChange={this.selectPickOne}
            options={this.getPicksForSelectedTeam(this.state.selectedTeamOne)}
          />
        </div>
        <div className="col s6">
          <Select
            class="team-select"
            id="team-two-select"
            label="Team"
            onChange={this.selectTeamTwo}
            options={this.state.secondTeamSelectOptions}
            preSelectedValue={this.state.selectedTeamTwo}
          />
          <Select
            class="pick-select"
            id="team-two-pick-select"
            label="Pick"
            multiple="true"
            onChange={this.selectPickTwo}
            options={this.getPicksForSelectedTeam(this.state.selectedTeamTwo)}
          />
        </div>
      </div>
      <div className="center-align row">
        <button className="btn waves-effect waves-light" type="submit">Perform Trade</button>
      </div>
    </form>`
