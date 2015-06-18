@Select = React.createClass
  changeHandler: (e) ->
    if typeof @props.onChange is 'function'
      @props.onChange(e.target.value)
  render: ->
    options = @props.options.map (option, i) ->
      `<option key={i} value={option.value}>{option.name}</option>`
    `<div>
      <select className={this.props.class} name={this.props.class} onChange={this.changeHandler}>
        {options}
      </select>
    </div>`
