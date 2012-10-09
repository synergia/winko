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
  # $("#nav a").hammer().on "tap", (e) ->
    # console.log $(this) #.attr("href")
    # console.log e
    # $("#home").hide()
    # $($(this).attr("href")).show()

$ ->
  initWebSocket("ws://192.168.0.29:5679")
  initNavigation()
