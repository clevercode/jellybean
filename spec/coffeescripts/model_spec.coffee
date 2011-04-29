describe 'Jellybean.Model', ->

  beforeEach ->
    class @Klass extends Jellybean.Model
      @setModelName 'Klass'
      @setAttributes ['id', 'text']
  
  it 'should exist', ->
    expect(Jellybean.Model).toBeDefined()


  describe 'subclassing', ->

    it 'should create a subclass', ->
      expect(@Klass).toBeDefined()
      expect(@Klass.modelName).toBe('Klass')

    it 'should set attributes', ->
      expect(@Klass.attributes).toContain 'id'
      expect(@Klass.attributes).toContain 'text'


  describe '#init(attributes)', ->

    beforeEach ->
      @k = @Klass.init({text: 'example'})

    it 'should create an object of the model type', ->
      expect(@k.modelName).toBe('Klass')

    it 'should create an unsaved object', ->
      expect(@k.newRecord).toBe(true)


  describe '#create(attributes)', ->

    beforeEach ->
      @k = @Klass.create({text: 'example'})

    it 'should create a saved object', ->
      expect(@k.newRecord).toBe(false)


  describe '#inst(attributes)', ->

    beforeEach ->
      @k = @Klass.inst({id: 1})

    it 'should create a saved object', ->
      expect(@k.newRecord).toBe(false)

    it 'should require an id', -> 
      fn = => @Klass.inst({})
      expect(fn).toThrow("An id is required to reinitialize a record")


