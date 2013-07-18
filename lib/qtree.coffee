exports.QuadTree = class QuadTree
  constructor: (@bounds,@maxChildren)->
    @root = new QuadTreeNode(@,@bounds)

  add: (point) =>
    return @root.add(point)

  remove: (point) =>
    @root.remove(point)

  find: (point) =>
    out = []
    @root.find(point, out)
    out

  findRange: (range) =>
    out = []
    @root.findRange(range, out)
    out

  move: (point,dx,dy) =>
    @root.remove(point)
    point.x += dx
    point.y += dy
    @root.add(point)

  maxDepth: =>
    o = {d:0}
    @root.maxDepth(o)
    o.d

class QuadTreeNode
  constructor: (@quadtree,@bounds) ->
    @points = []

  add: (point) ->
    return @ne.add(point) if @ne? and @_inRange(point,@ne.bounds)
    return @se.add(point) if @se? and @_inRange(point,@se.bounds)
    return @nw.add(point) if @nw? and @_inRange(point,@nw.bounds)
    return @sw.add(point) if @sw? and @_inRange(point,@sw.bounds)

    @points.push(point)
    @_split() if @points.length>@quadtree.maxChildren

  find: (point,out) ->
    return @ne.find(point,out) if @ne? and @_inRange(point,@ne.bounds)
    return @se.find(point,out) if @se? and @_inRange(point,@se.bounds)
    return @nw.find(point,out) if @nw? and @_inRange(point,@nw.bounds)
    return @sw.find(point,out) if @sw? and @_inRange(point,@sw.bounds)

    out.push(o) for o in @points when @_equal(o,point)

  findRange: (range, out) ->
    @sw.findRange(range,out) if @ne? and @_intersects(range,@sw.bounds)
    @se.findRange(range,out) if @se? and @_intersects(range,@se.bounds)
    @nw.findRange(range,out) if @nw? and @_intersects(range,@nw.bounds)
    @ne.findRange(range,out) if @sw? and @_intersects(range,@ne.bounds)

    for o in @points
      out.push o if @_inBounds(o.x,range.l,range.r) and @_inBounds(o.y,range.b,range.t)

  remove: (point) ->
    return @ne.remove(point,out) if @ne? and @_inRange(point,@ne.bounds)
    return @se.remove(point,out) if @se? and @_inRange(point,@se.bounds)
    return @nw.remove(point,out) if @nw? and @_inRange(point,@nw.bounds)
    return @sw.remove(point,out) if @sw? and @_inRange(point,@sw.bounds)

    out = []
    out.push(o) for o in @points when not @_equal(o,point)
    @points = out

    #return undefined unless @points.length > 0 or @se? or @sw? or @ne? or @nw?
    @

  _equal: (p1,p2) ->
    (p1.x == p2.x and p1.y == p2.y and (typeof(p2.v) == 'undefined' or p1.v == p2.v))

  _inRange: (point,range) ->
    (@_inBounds(point.x,range.l,range.r)) and (@_inBounds(point.y,range.b,range.t))

  _intersects: (r1,r2) ->
    (r1.l<r2.r && r1.r>r2.l && r1.b < r2.t && r1.t > r2.b)

  _inBounds: (v,min,max) ->
    (v>=min and v<=max)

  _split: ->
    splite = @bounds.l+(@bounds.r - @bounds.l)/2
    splitn = @bounds.b+(@bounds.t - @bounds.b)/2
    @ne ?= new QuadTreeNode(@quadtree,{l:splite, r:@bounds.r, b:splitn, t:@bounds.t})
    @se ?= new QuadTreeNode(@quadtree,{l:splite, r:@bounds.r, b:@bounds.b, t:splitn})
    @nw ?= new QuadTreeNode(@quadtree,{l:@bounds.l, r:splite, b:splitn, t:@bounds.t})
    @sw ?= new QuadTreeNode(@quadtree,{l:@bounds.l, r:splite, b:@bounds.b, t:splitn})

    for point in @points
      if @_inRange(point,@ne.bounds)
        @ne.add(point) 
      else if @_inRange(point,@se.bounds) 
        @se.add(point) 
      else if @_inRange(point,@nw.bounds)
        @nw.add(point) 
      else if @_inRange(point,@sw.bounds)
        @sw.add(point) 
    @points = []

  maxDepth: (o,d=1) ->
    o.d = d if o.d < d
    @ne.maxDepth(o,d+1) if @ne?
    @nw.maxDepth(o,d+1) if @nw?
    @se.maxDepth(o,d+1) if @se?
    @sw.maxDepth(o,d+1) if @sw?





