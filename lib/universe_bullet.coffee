_ = require 'underscore'
{Sprite} = require "../lib/universe_sprite"

exports.Bullet = class Bullet extends Sprite
  bullet: true
  shootable: true

  collisionIn: (sprite) =>
    #@server.destroySprite(@) if sprite.shootable
  
