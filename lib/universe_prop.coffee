_ = require 'underscore'
{Sprite} = require "../lib/universe_sprite"

exports.Prop = class Prop extends Sprite
  
  constructor: (@server, @pos, @speed, @cls, @propType) ->
    super

  collisionIn: (sprite) =>
    if sprite.player?
      switch @propType
        when 3
          sprite.player.health = Math.min(sprite.player.health+30, 100)
        when 4
          sprite.player.lowerSpeedLimit = 20
          sprite.player.upperSpeedLimit = 400
          sprite.player.speed = 400
        else
          sprite.player.fireMode = Math.max(sprite.player.fireMode, @propType+1)

      @server.removeProp(@)

  
