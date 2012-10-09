package synergia.winko

import unfiltered.netty.websockets._
import unfiltered.util._
import unfiltered.request._
import unfiltered.response._
import scala.collection.mutable.ConcurrentMap
import scala.collection.JavaConversions._
import java.util.concurrent.ConcurrentHashMap

object Bridge {
  val sockets: ConcurrentMap[Int, WebSocket] = new ConcurrentHashMap[Int, WebSocket]

  def broadcast(msg: String) = sockets.values.foreach { s =>
    if(s.channel.isConnected) s.send(msg)
  }
}

import TUIO._

object Listener extends TuioListener {

  def addTuioCursor(cur: TuioCursor) = sendCursor("add", cur)

  def updateTuioCursor(cur: TuioCursor) = sendCursor("update", cur)

  def removeTuioCursor(cur: TuioCursor) = sendCursor("remove", cur)

  def addTuioObject(obj: TuioObject){}

  def updateTuioObject(obj: TuioObject){}

  def removeTuioObject(obj: TuioObject){}

  def refresh(time: TuioTime){}

  protected def sendCursor(event: String, cur: TuioCursor) = {
    Bridge.broadcast(List(event, cur.getSessionID, cur.getX, cur.getY).mkString("|"))
  }
}

object App {

  def main(args: Array[String]) {
    val client = new TuioClient(3333)
    client.addTuioListener(Listener)
    client.connect()

    val wsHandler = unfiltered.netty.websockets.Planify {
      case _ => {
        case Open(s) =>
          Bridge.sockets += (s.channel.getId.intValue -> s)

        case Message(s, Text(msg)) =>
          Bridge.broadcast("%s|%s" format(s.channel.getId, msg))

        case Close(s) =>
          Bridge.sockets -= s.channel.getId.intValue

        case Error(s, e) =>
          e.printStackTrace
      }
    }

    val httpHandler = unfiltered.netty.cycle.Planify {
      case Path(Seg(Nil)) => ResponseString(html.index().toString()) ~> HtmlContent
      case _ => unfiltered.response.Pass
    }

    unfiltered.netty.Http(5679)
      .handler(wsHandler.onPass(_.sendUpstream(_)))
      .handler(httpHandler)
      .resources(getClass().getResource("/"), 40, passOnFail = false)
      .run()
  }
}
