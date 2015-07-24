@getFirstOption = (options) -> if _(options).any() then options[0].value else null
@getPlayerName = (player) ->
  if !!player.first_name
    "#{player.last_name}, #{player.first_name}"
  else
    player.last_name
@getSecondOption = (options) -> if _(options).any() then options[1].value else null
@getSelection = (options) ->
  selection = []
  selection.push(parseInt(option.value)) for option in options when option.selected
  selection

@Select = React.createClass
  changeHandler: (e) ->
    if typeof @props.onChange is 'function'
      selection = if @props.multiple then e.target.options else e.target.value
      @props.onChange(selection)
  render: ->
    options = @props.options.map (option, i) ->
      `<option key={i} value={option.value}>{option.name}</option>`
    `<div>
      <select multiple={this.props.multiple}
        className={this.props.class}
        id={this.props.id}
        name={this.props.class}
        onChange={this.changeHandler}
        value={this.props.preSelectedValue}
      >
        {options}
      </select>
    </div>`
