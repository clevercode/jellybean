# A Model is responsible for data validation, transformation, & persistence
# @example
#   class Message extends Jellybean.Model
#     @setModelName 'Message' 
#     @setAttributes ['body', 'user_id', 'created_at']
#     
#     initialize: (params) ->
#       // do something
#
class Jellybean.Model
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
      this.id = Jellybean.uid()
      this.model._records ||= {}
      this.model._records[this.id] = this
      this.model.trigger('new', this.clone()) if wasNewRecord
      this.sync() 
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

# Class Methods
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
