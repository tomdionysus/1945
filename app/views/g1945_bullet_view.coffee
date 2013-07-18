class App.G1945BulletView extends App.G1945SpriteView
  classHtml: 'g1945bullet'
  idPrefix: 'bullet'
  speed: {x:0, y:-8}
  type: 0
  damageValue: 10

  width:16
  height:16

  init: ->
    super
    @player = @findAncestorWithPrefix('player')

  afterRender: =>
    @element.addClass("g1945bulletType#{@type}")

  update: =>
    super
    @pos.x += @speed.x
    @pos.y += @speed.y

    if @pos.y < 0-128 or @pos.x < 0-128 or @pos.y > @parent.height+128 or @pos.x > @parent.width+128
      @parent.removeSprite(@)
    else
      @redopos()

  collisionIn: (sprite) =>
    super
    #console.log("#{@id} collisionIn #{@collides} / #{sprite.collides})")
    
    if @player? and sprite.hitValue?
      @player.set('score',@player.score + sprite.hitValue)

    if sprite.takeDamage?
      sprite.takeDamage(@damageValue)

    #@parent.removeSprite(@)




