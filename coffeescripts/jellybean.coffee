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

  Jb.uid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random()*16|0
      v = if c is 'x' then r else r & 0x3 | 0x8
      v.toString(16);
    ).toUpperCase();      
    

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
    initialize: -> null

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
        wasNewRecord = @newRecord
        @newRecord = false
        this.id = Jb.uid()
        this.model._records ||= {}
        this.model._records[this.id] = this
        this.model.trigger('new', this.clone()) if wasNewRecord
        console.log(wasNewRecord)
        return true
      else
        this.trigger('error', this, @errors)
        return false

    # Used by JSON.stringify to only serialize the attributes
    toJSON: ->
      return @attributes

    equals: (other) ->
      return this.id is other.id

    # Returns an entangled copy of this record. Making changes to this object's
    # attributes will update the copy and vice versa
    # ~ Inspired by Spine.js
    clone: ->
      Object.create(this)

  _(Model).extend
    _records: null
    setModelName: (name) ->
      @modelName = name

    setAttributes: (attributes) ->
      @attributes = attributes

    belongsTo: ( relation, options ) ->
      @_associations ||= {}
      @_associations['belongsTo'] ||= []
      association =
        name: relation
        foreign_key: relation+ '_id'
        className: options.className


    propertyDescriptors: ->
      return @_descriptors if @_descriptors?
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
      descriptors['model'] =
        value: this
      return @_descriptors = descriptors

    # Creates a new, unsaved instance of the model. Attributes of the model are
    # initialized with the passed object.
    init: (attributes) ->
      record = this.allocate()
      record.initWith(attributes: attributes)
      record.newRecord = true
      record.initialize()
      return record
   
    # Creates a new instance of the model and saves it.
    create: (attributes) ->
      record = this.init(attributes)
      # record.beforeCreate
      record.save()
      # record.afterCreate
      return record

    # Builds an instance of the model
    allocate: ->
      return Object.create(@::, @propertyDescriptors())

    # Wakes a model up from persistence
    inst: (attributes) ->
      # All reinitialized records should come pre-filled with their id.
      throw "An id is required to reinitialize a record" unless attributes.id 
      record = this.allocate()
      record.initWith(attributes: attributes)
      record.newRecord = false
      return record
    
    refresh: (values) ->
      @_records = {}
      for value in values
        record = this.inst(value)
        @_records[record.id] = record
      this.trigger('refresh')

    records: ->
      return (record.clone() for own key, record of @_records)

    find: (id) ->
      if record = @_records[id.toString()]
        return record.clone()
      else
        throw new Error("RecordNotFound: No record exists for id: #{id}")
        return undefined

  # Mixin the Events methods
  _(Model).extend(Events)
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

    constructor: (options = {}) ->
      @options = options
      this.initialize()

    initialize: -> null

  _(ViewController::).extend(Events)

       

  View = class Jb.View

    tag: 'div'
    
    constructor: (element, options = {}) ->
      @subviews = []
      @element = element
      @options = options
      this._ensureElementExists()
      this.initialize()

    initialize: -> null

    # Container element for view
    element: null

    # jQuery in the context of this View
    $: (selector) ->
      unless @element?
        return $([])
      @_cached$ ||= $(@element)
      if selector?
        return @_cached$.find(selector)
      else
        return @_cached$

    # Update contents 
    render: -> 
      subview.render() for subview in @subviews

    addSubview: (aSubview)->
      @subviews.push(aSubview)
      @element.appendChild(aSubview.element)

    _ensureElementExists: ->
      unless @element?
        @element = document.createElement(@tag)

  _(View::).extend(Events)

  class Jb.ScrollView extends Jb.View
    initialize: ->
      super()
      this.$().bind 'mousewheel', (event) =>
        delta = event.wheelDelta / 5
        newY = this.$().scrollTop() + delta
        this.$().scrollTop(newY)
        return false


  class Jb.TableViewController extends Jb.ViewController

    tableStyle: 'JBDefaultTableStyle'
    currentSelection: null
    currentSelectionClassName: 'selected'
 
    initialize: () ->
      @data = []
      @view = new Jb.TableView(@options.element, style: this.tableStyle)
      @view.delegate = this

    # Defaults
    numberOfSections: -> 
      1
    numberOfRowsInSection: ->
      0
    numberOfRows: ->
      0



  class Jb.TableView extends Jb.ScrollView
    tag: 'ul'
    delegate: null
    currentSelection: null
    visibleCells: null
    template: Handlebars.compile '''
      <li>
        <header>{{title}}</header>
        <ul></ul>
      </li>
    '''

    initialize: ->
      super()
      @visibleCells = []
      @selectedIndex = null
      this.$()
        .addClass(@options['style']) 
      this.bindEvents()

    bindEvents: -> 
      this.$().delegate 'li li', 'click', (e) =>
        e.preventDefault()
        this.setSelectedIndex(this.$('li li').index(e.target))

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
        $section = Jb.$(@template({title: @delegate.titleForSection(section)}))
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
      
      this.$().empty().append(sections)


  class Jb.TableCell extends View
    template: Handlebars.compile('''
      {{label}}
    ''')

    label: null

    initialize: ->
      @element = document.createElement('li')
      this.$().addClass(@style) if @style

    setSelected: (state) ->
      if state
        this.$().addClass('selected')
      else
        this.$().removeClass('selected')

    render: ->
      content = @template(this)
      @element.innerHTML = content



  # return to global scope
  return Jb
