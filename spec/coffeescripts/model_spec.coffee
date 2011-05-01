describe 'Jellybean.Model', ->

  class Klass extends Jellybean.Model
    @setModelName 'Klass'
    @setAttributes ['id', 'text']
  
  it 'should exist', ->
    expect(Jellybean.Model).toBeDefined()


  describe 'subclassing', ->

    it 'should create a subclass', ->
      expect(Klass).toBeDefined()
      expect(Klass.modelName).toBe('Klass')

    it 'should set attributes', ->
      expect(Klass.attributes).toContain 'id'
      expect(Klass.attributes).toContain 'text'


  describe 'Model.init(attributes)', ->

    beforeEach ->
      @k = Klass.init({text: 'example'})

    it 'should create an object of the model type', ->
      expect(@k.modelName).toBe('Klass')

    it 'should create an unsaved object', ->
      expect(@k.newRecord).toBe(true)


  describe 'Model.create(attributes)', ->

    beforeEach ->
      @k = Klass.create({text: 'example'})

    it 'should create a saved object', ->
      expect(@k.newRecord).toBe(false)


  describe 'Model.inst(attributes)', ->

    beforeEach ->
      @k = Klass.inst({id: 1})

    it 'should create a saved object', ->
      expect(@k.newRecord).toBe(false)

    it 'should require an id', -> 
      fn = => Klass.inst({})
      expect(fn).toThrow("An id is required to reinitialize a record")

  describe 'Model.allocate', ->

    it 'should create the object without initializing it', ->
      @k = Klass.allocate()
      expect(@k.newRecord).not.toBeDefined()
      expect(@k.attributes).toBeNull()

  describe '#read(attr)', ->

    beforeEach ->
      @k = Klass.init({text: 'example text'})

    it 'should return the value from the attributes hash', ->
      expect(@k.read('text')).toEqual('example text')
    it 'should be used by the property accessor', ->
      spyOn(@k, 'read')
      @k.text
      expect(@k.read).toHaveBeenCalledWith('text')

  describe '#write(attr, val)', ->
    
    it 'should return the value assigned to it', ->
      k = Klass.init({})
      result = k.write('text', 'example text')
      expect(result).toEqual('example text')

    it 'should be used by the property accessor', ->
      k = Klass.init({})
      spyOn(k, 'write')
      k.text = 'example text'
      expect(k.write).toHaveBeenCalledWith('text','example text')

    it 'should be used when initializing the attributes', ->
      spyOn(Klass::, 'write')
      k = Klass.init(text: 'example text')
      expect(Klass::write).toHaveBeenCalledWith('text', 'example text')

  describe '#clone()', ->
    
    k = null
    c = null

    beforeEach ->
      k = Klass.init()
      c = k.clone()

    it 'should create a copy with entangled attributes', ->
      k.text = 'example text'
      expect(c.text).toEqual(k.text)
      k.text = 'new example text'
      expect(c.text).toEqual(k.text)
      c.text = 'quantum entanglement'
      expect(k.text).toEqual(c.text)

    it 'should create a copy with entangled events', ->
      callback1 = jasmine.createSpy()
      callback2 = jasmine.createSpy()
      # check for events fired on the clone
      k.bind('call1', callback1)
      c.trigger('call1')  
      expect(callback1).toHaveBeenCalled()
      # check for events fired on the original
      c.bind('call2', callback2)
      k.trigger('call2')
      expect(callback2).toHaveBeenCalled()




