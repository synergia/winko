WIDTH = 600
HEIGHT = 400
SMALL_DISTANCE = 0.005

App =
  cursors: {}
  objects: {}

  calculatePos: (x,y) ->
    [x*WIDTH, y*HEIGHT]

  callbacks:
    init: ->
      $("#container").css({width: WIDTH, height: HEIGHT})

      $("#button1").click () ->
        alert("Clicked!")

    click: (x,y) =>
      console.log "click #{x} x #{y}"
      [xp, yp] = App.calculatePos(x,y)
      el = document.elementFromPoint(xp,yp)
      console.log [x, y, xp, yp, el]
      $(el).click()


@tuio.object_add (data) ->
  console.log('[object] add: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y + ', angle=' + data.angle)

@tuio.object_update (data) ->
  console.log('[object] update: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y + ', angle=' + data.angle)

@tuio.object_remove (data) ->
  console.log('[object] remove: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y + ', angle=' + data.angle)

@tuio.cursor_add (data) ->
  App.cursors[data.sid] =
    origin:
      x: data.x
      y: data.y

  # console.log('[cursor] add: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y)

@tuio.cursor_update (data) ->
  # App.cursors[data.sid] = data
  # console.log('[cursor] update: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y)

isSmallDistance = (x1, y1, x2, y2) ->
  Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2) < SMALL_DISTANCE

@tuio.cursor_remove (data) ->
  origin = App.cursors[data.sid].origin

  if isSmallDistance(origin.x, origin.y, data.x, data.y)
    App.callbacks.click(origin.x, origin.y)

  delete App.cursors[data.sid]
  # console.log('[cursor] remove: sid=' + data.sid + ', fid=' + data.fid + ', x=' + data.x + ', y=' + data.y)


@init = () ->
  tuio.start()
  App.callbacks.init()

