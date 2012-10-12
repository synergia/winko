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
    id = $(this).attr("href")
    $("#home").hide()
    $(id).show()
    Apps[id]()


Apps =
  "#map": () ->
    map = L.map('map-content').setView([51.505, -0.09], 13)
    L.tileLayer('http://{s}.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/997/256/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
      maxZoom: 18
    }).addTo(map)

  "#color": () ->



$ ->
  initWebSocket("ws://192.168.0.29:5679")
  initNavigation()
