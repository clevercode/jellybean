#= require underscore 
#= require handlebars

@['Jellybean'] = do ->

  # The Jb object we're building
  Jb = {}

  # Keep a reference to jQuery & Underscore
  $ = Jb.$ = @jQuery
  _ = Jb._ = @_


  Jb.uid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random()*16|0
      v = if c is 'x' then r else r & 0x3 | 0x8
      v.toString(16);
    ).toUpperCase();      
    



  Sync = class Jb.Sync

    constructor: ->
      @commited = no

    commit: ->
      @committed = yes


  Http = Jb.Http =

    get: (ids...) ->

    post: (object) ->

    put: -> (object) ->

    delete: -> (object) ->

    bulk_post: -> (objects)





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
