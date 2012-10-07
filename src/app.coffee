@tuio.object_add (data) ->
  console.log('[object] add: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y + ', angle=' + data.angle)

@tuio.object_update (data) ->
  console.log('[object] update: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y + ', angle=' + data.angle)

@tuio.object_remove (data) ->
  console.log('[object] remove: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y + ', angle=' + data.angle)

@tuio.cursor_add (data) ->
  console.log('[cursor] add: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y)

@tuio.cursor_update (data) ->
  console.log('[cursor] update: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y)

@tuio.cursor_remove (data) ->
  console.log('[cursor] remove: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y)


@init = () ->
  console.log "starting"
  tuio.start()
  console.log(tuio)
