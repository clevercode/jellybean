@['Jellybean'] = do ->

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
    attributes: null
    afterInit: -> null

    initWith: (properties) ->
      @attributes = {}
      if attrs = properties.attributes
        this.write(attr, val) for attr, val of attrs

      # initialize the callbacks hash so that it can be cloned
      @_callbacks = {}

      return this

    # #write is used to set values of the attributes hash
    # Its used internally by the dynamic property readers
    read: (attr) ->
      @attributes[attr]

    # #write is used to set values of the attributes hash
    # Its used internally by the dynamic property writers
    write: (attr, val) ->
      @attributes[attr] = val
      this.trigger('changed')
      return val

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

    # Used by JSON.stringify to only serialize the attributes
    toJSON: ->
      return @attributes

    # Returns an entangled copy of this record. Making changes to this object's
    # attributes will update the copy and vice versa
    # ~ Inspired by Spine.js
    clone: ->
      Object.create(this)

  
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
    record.initWith(attributes: attributes)
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
    record.initWith(attributes: attributes)
    record.newRecord = false
    return record
    
  # Mixin the Events methods
  _(Model::).extend(Events)

  #
  # Jellybean Controllers
  #

  # A ViewController follows the role of a controller in typical MVC fashion. It's
  # job is to keep the element on screen (View) in sync with the underlying
  # data its representing (Model)
  ViewController = class Jb.ViewController 
    title: null
    view: null


  _(ViewController::).extend(Events)

       

  View = class Jb.View
    
    constructor: (element, options = {}) ->
      @element = element
      @options = options
      this.initialize()

    initialize: -> null

    # Container element for view
    element: null

    # jQuery in the context of this View
    $: (selector) ->
      Jb.$(selector or @element, @element)

    # Update contents 
    render: -> null

  _(View::).extend(Events)

  class Jb.TableViewController extends ViewController

    tableStyle: 'JBDefaultTableStyle'
    currentSelection: null
    currentSelectionClassName: 'selected'
 
    constructor: (options = {}) ->
      @data = []
      @view = new Jb.TableView(options.element, style: this.tableStyle)
      @view.delegate = this
      this.initialize() if @initialize


  class Jb.TableView extends View
    delegate: null
    currentSelection: null
    visibleCells: null
    template: Handlebars.compile '''
      <li>
        <h1>{{title}}</h1>
        <ul></ul>
      </li>
    '''

    initialize: ->
      super()
      @visibleCells = []
      @selectedIndex = null
      Jb.$(@element)
        .addClass(@options['style']) 
      this.bindEvents()

    bindEvents: -> 
      $(@element).delegate 'a', 'click', (e) =>
        e.preventDefault()
        this.setSelectedIndex(this.$('a').index(e.target))

    setSelectedIndex: (index) ->
      # Don't reselect the same item
      if index is @selectedIndex
        return false
      # Unselect the current selection
      if @selectedIndex?
        @visibleCells[@selectedIndex].setSelected(no)
      @selectedIndex = index
      @visibleCells[@selectedIndex].setSelected(yes)
      @delegate.didSelectIndex(@selectedIndex)
      return true

    render: ->
      rowIndex = 0
      lastRowInSection = 0
      renderSection = (section) =>
        $section = $(@template({title: @delegate.titleForSection(section)}))
        $sectionList = $section.children('ul') 
        lastRowInSection += @delegate.numberOfRowsInSection(section)
        while rowIndex < lastRowInSection
          cell = @delegate.cellForRowAtIndex(rowIndex)
          cell.render()
          @visibleCells.push(cell)
          $sectionList.append(cell.element)
          rowIndex++
        return $section[0]

      sections = (renderSection(section) for section in [0...@delegate.numberOfSections()])
      
      this.$(@element).empty().append(sections)


  class Jb.SimpleCellView extends View
    template: Handlebars.compile('''
        {{#if anchor}}
          <a href="{{anchor}}">{{label}}</a> 
        {{else}}
          {{label}}
        {{/if}}
    ''')
    label: null
    anchor: null

    initialize: ->
      @element = document.createElement('li')

    setSelected: (state) ->
      if state
        this.$('a').addClass('selected')
      else
        this.$('a').removeClass('selected')

    render: ->
      content = @template({label: @label, anchor: @anchor})
      @element.innerHTML = content



  # return to global scope
  return Jb
