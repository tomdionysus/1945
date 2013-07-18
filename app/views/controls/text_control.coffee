class App.TextControl extends Mozart.Control
  templateName: 'app/templates/controls/text_control'
  disableHtmlAttributes: true

  init: ->
    super()
    @controlId = "#{@id}-tbx"
    @bind 'change:value', @updateInputValue
      
  afterRender: =>
    super()
    @controlEl = $("##{@controlId}")
    @copyHtmlAttrsToElement(@controlEl)
    @controlEl[0].type = @typeHtml if @typeHtml?
    @updateInputValue()
    @element

  updateInputValue: =>
    return null unless @controlEl?
    @controlEl.val(@value) unless @writing 

  focus: ->
    @controlEl.focus()

  cancel: ->
    @set 'value', @origValue
    @controlEl.val(@value)
    @controlEl.blur()
    
  keyUp: (e) ->
    @writing = true
    @set 'value', @controlEl.val()
    @writing = false