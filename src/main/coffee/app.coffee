console.log "init"

# hack for touch-enabled detection
document.ontouchstart = null
document.documentElement.ontouchstart = null

initWebSocket = (uri) ->
  window.socket = socket = if window.WebSocket then new WebSocket(uri) else new MozWebSocket(uri)

  console.log socket

  socket.onopen = (e) ->
    console.log "WebSocket connection open"

  socket.onmessage = (e) ->
    # console.log "WebSocket data: #{e.data}"

    [ev, sid, x, y] = e.data.split("|")

    evid = switch ev
      when "add" then 3
      when "update" then 4
      when "remove" then 5

    magictouch_tuio_callback(evid, sid, 1, x, y, 0)

  socket.onclose = (e) ->
    console.log "WebSocket connection closed"

initNavigation = () ->
  $("#nav a").hammer().on "tap click", (e) ->
    CurrentApp?.stop()

    id = $(this).attr("href")
    $("#home").hide()
    $(id).show()
    CurrentApp = Apps[id]
    CurrentApp.start()

  console.log "nav init"

  control = {}
  control.back = null

  $("#control-back").hammer(
    hold: true
  ).on("hold", (e) ->
    CurrentApp?.stop()
    $(".app").hide()
    $("#home").show()
  ).on("touchstart", (e) ->
    $("#control-back").addClass("active")
  ).on("touchend", (e) ->
    $("#control-back").removeClass("active")
  )



class Map
  start: () ->
    $("#map-content").remove()
    $("#map .full").html("<div id='map-content'></div>")
    window.map = map = L.map('map-content', {
      zoomControl: false
    }).setView([51.505, -0.09], 13)

    L.tileLayer('http://{s}.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/997/256/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
      maxZoom: 18
    }).addTo(map)

  stop: () ->
    $("#map-content").remove()

class Color
  start: () =>
    $("#color-canvas").remove()
    $("#color .full").html("<canvas id='color-canvas''></canvas>")
    @drawingCanvas = document.getElementById('color-canvas')
    @drawingCanvas.width = window.innerWidth
    @drawingCanvas.height = window.innerHeight

    @ctx = @drawingCanvas.getContext('2d')
    @ctx.lineCap = 'round'
    @ctx.lineWidth = 5

    @points = []

    @hammer = new Hammer(@drawingCanvas, {
      hold: false,
      tap: false,
      tap_double: false,
      drag: true,
      drag_vertical: true,
      drag_horizontal: true,
      transform: false,
      prevent_default: true
    })

    @hammer.ondrag = (event) =>
      for e in event.touches
        @points.unshift(x: e.x, y: e.y)

      @points.splice(100, 100)

      false


    @_int = setInterval(@draw, 1000/35)

  randomHSLColor: (lightness) =>
    "hsl(#{Math.round(Math.random() * 255)}, 100%, #{Math.round(lightness/2)}%)"

  draw: () =>
    @ctx.fillStyle = 'rgb(0,0,0)'
    @ctx.fillRect(0, 0, @drawingCanvas.width, @drawingCanvas.height)

    for i in [100..0]
      p = @points[i]
      @drawDot(p.x, p.y, 100-i) if p

  drawDot: (x, y, opacity) =>
    @ctx.fillStyle = @randomHSLColor(opacity)
    @ctx.beginPath()
    @ctx.arc( x, y, ((opacity*3) / 10), 0, Math.PI*2, true )
    @ctx.closePath()
    @ctx.fill()


  stop: () ->
    @_int = clearInterval(@_int)
    $("#color-canvas").remove()

class Debug
  start: () =>
    $("#debug-canvas").remove()
    $("#debug .full").html("<canvas id='debug-canvas''></canvas>")
    @drawingCanvas = document.getElementById('debug-canvas')
    @drawingCanvas.width = window.innerWidth
    @drawingCanvas.height = window.innerHeight

    @ctx = @drawingCanvas.getContext('2d')
    @ctx.lineCap = 'round'
    @ctx.lineWidth = 5

    @_int = setInterval(@draw, 1000/35)

    @_colors = (@randomHSLColor(100) for i in [0..100])

  randomHSLColor: (lightness) =>
    "hsl(#{Math.round(Math.random() * 255)}, 100%, #{Math.round(lightness/2)}%)"

  draw: () =>
    @ctx.fillStyle = 'rgb(0,0,0)'
    @ctx.fillRect(0, 0, @drawingCanvas.width, @drawingCanvas.height)

    for p,i in tuio.cursors
      @drawDot(p.clientX, p.clientY, p.identifier, @_colors[i])

  drawDot: (x, y, n, color) =>
    @ctx.fillStyle = color
    @ctx.beginPath()
    @ctx.arc(x, y, 30, 0, Math.PI*2, true )
    @ctx.closePath()
    @ctx.fill()

    @ctx.font = '20px Moncao, Arial, sans-serif';
    @ctx.textAlign = "center"
    @ctx.textBaseline = "middle"
    @ctx.fillStyle = 'rgb(0,0,0)'
    @ctx.fillText(n, x, y)



  stop: () ->
    @_int = clearInterval(@_int)
    $("#debug-canvas").remove()


CurrentApp = null
Apps =
  "#map": new Map()
  "#color": new Color()
  "#debug": new Debug()



$ ->
  initWebSocket("ws://156.17.14.226:5679")
  initNavigation()
