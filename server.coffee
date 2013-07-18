express = require 'express'
io = require 'socket.io'
http = require 'http'
{QuadTree} = require './lib/qtree'
{Server} = require './lib/universe_server'

app = express()
app.use(express.static('public'))

server = http.createServer(app)
io = io.listen(server, { log: false })

console.log("Universe Server Started")
app = new Server(io)
server.listen(process.env.PORT || 5000)