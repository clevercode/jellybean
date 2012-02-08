Jellybean.Sync
==============

A sync object handles persisting objects to the database.
It can handle single or bulk operations.


## Jellybean.Sync.current

This is the currently unsynced set of interactions. 


### Jellybean.Sync.commit()

This decides if the sync has changes to persist, then actually calls the
underlying AJAX persistence to make it happen. Then it creates a new Sync
object to replace the current Sync object

`#commit` should be called at the end of a single user interaction.


## Intended use

    Jellybean.Sync.add(post)
    Jellybean.Sync.add([comment, comment])

    Jellybean.Sync.current
    #=> { 
          committed: false,
          objects: [<Post>, <Comment>, <Comment>]
        }

    Jellybean.Sync.commit()
    #=> $.Deferred

More often than not, you won't track the deferred. Most things will be
observing the objects that are synced, and they'll get notified individually.




### JSON payload:

    { posts: [
        { id: 1, title: 'Hello World', body: 'Something is super cool.'},  
        { id: 2, title: 'Hello World 2', body: 'Something else that is super cool.'}  
      ]
      comments: [
        { commenter: 'Andrew Smith', text: 'This is pretty awesome', post_id: 1}
    }

### Payload split logic

  if !object.id?
    # its a new object, add it to the POST list
  if object.id? 


    
    
