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
