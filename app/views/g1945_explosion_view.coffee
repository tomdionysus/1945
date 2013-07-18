class App.G1945ExplosionView extends App.G1945SpriteView
  size: 'small'
  collides: false

  init: ->
    super
    @classHtml = "g1945explosion_#{@size}"

  afterRender: =>
    super
    _.delay(=>
      @parent.removeSprite(@)
    ,2000)

  update: =>
    super
    if @speed?
      @pos.x += @speed.x
      @pos.y += @speed.y

    @redopos()
