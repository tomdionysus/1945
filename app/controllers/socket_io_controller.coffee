class App.SocketIoController extends Mozart.Controller

  connect: (host) ->
    @socket = io.connect(host)
    @socket.on 'connect', ->
      console.log("server connected")

    @socket.on 'disconnect', ->
      console.log("server disconnected")

    @socket.on 'st', @onState

  disconnect: ->
    @socket.disconnect()

  onState: (data) =>
    @trigger('gameEvent',data)

  command: (data) ->
    @socket.emit('command',data)
  