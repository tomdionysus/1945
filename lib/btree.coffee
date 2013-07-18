exports.BinaryTreeNode = class BinaryTreeNode

  constructor: (@k,@v) ->
    @l = null
    @r = null

  add: (k, v) ->
    if k > @k 
      unless @r?
        @r = new BinaryTreeNode(k,v)
      else
        @r.add(k,v)
    else
      unless @l
        @l = new BinaryTreeNode(k,v)
      else
        @l.add(k,v)

  find: (k) ->
    x = @findNode(k)
    return null unless x?
    x.v

  remove: (k,v=null) ->
    if @k == k and (v == null or @v == v)
      return @r unless @l?
      return @l unless @r?
      node = @l
      node.addNode(@r)
      node = node.remove(k,v)
      return node
    else
      if k > @k and @r?
        @r = @r.remove(k,v)
      else if @l?
        @l = @l.remove(k,v)
      return @

  addNode: (node) ->
    return unless node?
    if node.k > @k 
      unless @r?
        @r = node
      else
        @r.addNode(node)
    else
      unless @l?
        @l = node
      else
        @l.addNode(node)

  findNode: (k) ->
    node = @
    while node.k != k
      if k > node.k
        return null unless node.r?
        node = node.r
      else
        return null unless node.l?
        node = node.l
    node

  findAllNodes: (k, out) ->
    node = @findNode(k)
    return unless node?
    out.push node
    node.l.findAllNodes(k, out) if node.l?

  countLeft: ->
    node = @
    i = -1
    while node?
      i++
      node = node.l
    i

  countRight: ->
    node = @
    i = -1
    while node?
      i++
      node = node.r
    i

  optimize: ->
    x = Math.floor((@countLeft()-@countRight())/2)
    node = @
    while x!=0
      if x>0
        tnode = node.l
        node.l = null
        tnode.addNode(node)
        node = tnode
        x--
      else
        tnode = node.r
        node.r = null
        tnode.addNode(node)
        node = tnode
        x++
    node.l = node.l.optimize() if node.l?
    node.r = node.r.optimize() if node.r? 
    node

  walk: (callback, forward) ->
    if forward
      @l.walk(callback, forward) if @l? 
      callback(@)
      @r.walk(callback, forward) if @r? 
    else
      @r.walk(callback, forward) if @r? 
      callback(@)
      @l.walk(callback, forward) if @l? 

  rangeQuery: (callback, min, max) ->
    if @k < min
      @r.rangeQuery(callback, min, max) if @r?
    else if @k > max
      @l.rangeQuery(callback, min, max) if @l?
    else
      @l.rangeQuery(callback, min, max) if @l?
      callback @
      @r.rangeQuery(callback, min, max) if @r?

  max: ->
    node = @
    while node?
      max = node
      node = node.r
    max

  min: ->
    node = @
    while node?
      max = node
      node = node.l
    max

exports.BinaryTree = class BinaryTree
  constructor: ->
    @root = null

  add: (k, v) ->
    unless @root?
      @root = new BinaryTreeNode(k, v)
    else
      @root.add(k, v)

  find: (k) ->
    return null unless @root?
    @root.find(k)

  findAll: (k) ->
    return [] unless @root?
    out = []
    @root.findAllNodes(k,out)
    (o.v for o in out)

  contains: (k) ->
    @find(k)?

  remove: (k,v=null) ->
    return null unless @root?
    @root = @root.remove(k,v)

  optimize: ->
    return null unless @root?
    @root = @root.optimize()

  walk: (callback, forward) ->
    return null unless @root?
    @root.walk(callback, forward)

  range: (callback, min, max) ->
    return null unless @root?
    @root.rangeQuery(callback, min, max)

  minNode: ->
    return null unless @root?
    @root.min()
  
  min: ->
    return null unless @root?
    node = @minNode()
    node.v

  maxNode: ->
    return null unless @root?
    @root.max()

  max: ->
    return null unless @root?
    node = @maxNode()
    node.v

  all: ->
    out = []
    @walk((node) ->
      out.push(node)
    ,true)
    out
