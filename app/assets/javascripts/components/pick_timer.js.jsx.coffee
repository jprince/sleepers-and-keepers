@pickDuration = 120
@PickTimer = createReactClass
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
