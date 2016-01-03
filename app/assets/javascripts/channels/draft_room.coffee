App.draftRoom = App.cable.subscriptions.create "DraftRoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    console.log data

  refresh: (data) ->
    @perform 'refresh', refreshedData: data
