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
    attributes: {}

    afterInit: -> null

    # #write is used to set values of the attributes hash
    # Its used internally by the dynamic property readers
    read: (attr) ->
      @attributes[attr]

    # #write is used to set values of the attributes hash
    # Its used internally by the dynamic property writers
    write: (attr, val) ->
      @attributes[attr] = val
      this.trigger('changed')

    # To update and save a single attribute
    updateAttribute: (attr, val) ->
      this.write(attr, val)
      this.save()

    # To update and save one or more attributes
    updateAttributes: (newAttributes) ->
      this.write(attr, val) for attr, val of newAttributes
      this.save()

    validate: -> 
      @errors = []
      return true

    save: ->
      if this.validate()
        this.trigger('update', this)
        @newRecord = false
        return true
      else
        this.trigger('error', this, @errors)
        return false
  
  Model.setModelName = (name) ->
    @modelName = name

  Model.setAttributes = (attributes) ->
    @attributes = attributes

  Model.propertyDescriptors = ->
    descriptors = {}
    for attribute in @attributes
      do(attribute) ->
        descriptors[attribute] = 
          get: -> this.read(attribute)
          set: (val) -> this.write(attribute, val)
          enumerable: true
    # sets the modelName of the object
    descriptors['modelName'] = 
      value: @modelName
      writable: false

    return descriptors


  # Creates a new, unsaved instance of the model. Attributes of the model are
  # initialized with the passed object.
  Model.init = (attributes) ->
    record = this.allocate()
    record.attributes = attributes
    record.newRecord = true
    return record
 
  # Creates a new instance of the model and saves it.
  Model.create = (attributes) ->
    record = this.init(attributes)
    # record.beforeCreate
    record.save()
    # record.afterCreate
    return record

  # Builds an instance of the model
  Model.allocate = ->
    return Object.create(@::, @propertyDescriptors())

  # Wakes a model up from persistence
  Model.inst = (attributes) ->
    # All reinitialized records should come pre-filled with their id.
    throw "An id is required to reinitialize a record" unless attributes.id 
    record = this.allocate()
    record.attributes = attributes
    record.newRecord = false
    return record
    


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

  ###
    @class Jellybean.NestedListViewController  
    Used to display a list of lists, where the items of the secondary lists are
    selectable

    Events: selection
  ###
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

  ###
    Views
  ###
  
  ### 
    View is the base of all defined views
  ###
  View = class Jb.View

    # Container element for view
    element: null

    # jQuery in the context of this View
    $: (selector) ->
      Jb.$(selector, @element)

    # Update contents 
    render: -> null




  _(View::).extend(Events)

  ###
     ScrollView
  ###
  ScrollView = class Jb.ScrollView extends View

  ###
    @class TableView
  ###
  class Jb.TableView extends ScrollView
    

  ###
    @class TableCellView
  ###
  class Jb.TableCellView extends ViewController
    template: '<tr><td>{{body}}</td></tr>'

  # return to global scope
  return Jb
)()
