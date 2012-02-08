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
