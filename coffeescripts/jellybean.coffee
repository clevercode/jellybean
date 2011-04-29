@['Jellybean'] = ( ->

  # The Jb object we're building
  Jb = {}

  # Keep a reference to jQuery & Underscore
  $ = Jb.$ = @jQuery
  _ = Jb._ = @_

  # Events is a mixin that provides common methods for binding and triggering events
  Events = Jb.Events = 
    bind: (event_type, callback) ->
      types = event_type.split(' ')
      @_callbacks ||= {}
      # Add the callback to a new or existing list
      for type in types
        @_callbacks[type] ||= []
        @_callbacks[type].push(callback)

      return this

    unbind: (event_type, callback) ->
      # Remove all callbacks for all events if no event is specified
      unless event_type
        @_callbacks = {}
        return this

      # Remove all callbacks for specific event if no callback is specified
      unless callback
        delete @_callbacks[event_type] = []
        return this

      # Remove a specific callback for a specific event
      @_callbacks[event_type] = _(@_callbacks[event_type]).without(callback)
      

    trigger: (event_type, args...) ->
      # fail fast
      return this unless @_callbacks
      return this unless @_callbacks[event_type]

      # invoke each callback with the supplied args
      callback.apply(this, args) for callback in @_callbacks[event_type]

      return this

  # A Controller follows the role of a controller in typical MVC fashion. It's
  # job is to keep the element on screen (View) in sync with the underlying
  # data its representing (Model)
  Controller = class Jb.Controller
    el: null    

    constructor: (params) ->
      @el = params.el if params.el

  # Mixin the Events methods
  _(Controller::).extend(Events)


  # A Model is responsible for data validation, transformation, & persistence
  # @example
  #   class Message extends Jellybean.Model
  #     @setModelName 'Message' 
  #     @setAttributes ['body', 'user_id', 'created_at']
  #     
  #     initialize: (params) ->
  #       // do something
  #
  Model = class Jb.Model
    id: null
    attributes: {}
  
  Model.setModelName = (name) ->
    @modelName = name

  Model.setAttributes = (attributes) ->
    @attributes = attributes

  # Mixin the Events methods
  _(Model::).extend(Events)


  ###
    Jellybean Controllers
  ###

  ###
    A ViewController follows the role of a controller in typical MVC fashion. It's
    job is to keep the element on screen (View) in sync with the underlying
    data its representing (Model)
  ###
  ViewController = class Jb.ViewController 

    # The HTMLElement that contains everything within this controllers scope
    view: null    

    initialize: -> 

    constructor: (params) ->
      @initialParams = params
      if params
        @view = params.view if params.view
        @selector = params.selector if params.selector
      this._findView() unless @view

      this.initialize()

    # jQuery in the context of this View
    $: (selector) ->
      Jb.$(selector, @view)

    # Use jQuery to find the first element the selector returns
    _findView: ->
      if @selector
        if el = Jb.$(@selector)[0]
          @view = el
          return @view
        else
          return false


  _(ViewController::).extend(Events)

  class Jb.NestedListViewController extends ViewController

    currentSelection: null
    currentSelectionClassName: 'selected'
 
    constructor: (view) ->
      super(view: view)
      @currentSelection = this.$('.'+@currentSelectionClassName)[0]
      this.bindEvents()

    bindEvents: -> 
      $(@view).delegate 'a', 'click', (e) =>
        e.preventDefault()
        unless @currentSelection is e.target
          @currentSelection = e.target
          this.trigger('selection', @currentSelection)
          this.updateView()

    updateView: ->
      this.$('.'+@currentSelectionClassName).removeClass(@currentSelectionClassName)
      this.$(@currentSelection).addClass(@currentSelectionClassName)


  # return to global scope
  return Jb
)()
