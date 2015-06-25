@Team = React.createClass
  render: ->
    `<h3>{this.props.name}</h3>`

@TeamsIndex = React.createClass
  render: ->
    teams = this.props.teams.map (team, i) -> `<Team key={i} name={team.name} />`
    `<div>
      <h2>Teams</h2>
      {teams}
     </div>`
