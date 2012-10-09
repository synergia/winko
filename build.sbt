organization := "synergia"

name := "winko"

version := "0.1.0"

libraryDependencies ++= Seq(
  "net.databinder" %% "unfiltered-netty-websockets" % "0.6.4",
  "net.sourceforge.tuio" % "tuio" % "1.4"
)

seq(coffeeSettings: _*)

seq(Revolver.settings: _*)

seq(Twirl.settings: _*)

