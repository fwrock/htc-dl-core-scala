ThisBuild / version := "0.1.0"
ThisBuild / scalaVersion := "3.3.6"
ThisBuild / organization := "io.github.fwrock"

lazy val root = (project in file("."))
  .settings(
    name := "htc-dl",
    description := "HTC Digital Twin Language - Parser, validator and code generator for HTCDL models",
    
    libraryDependencies ++= Seq(
      // JSON processing
      "io.circe" %% "circe-core" % "0.14.6",
      "io.circe" %% "circe-generic" % "0.14.6",
      "io.circe" %% "circe-parser" % "0.14.6",
      
      // Validation
      "org.typelevel" %% "cats-core" % "2.10.0",
      "org.typelevel" %% "cats-effect" % "3.5.4",
      
      // Testing
      "org.scalatest" %% "scalatest" % "3.2.17" % Test,
      "org.scalacheck" %% "scalacheck" % "1.17.0" % Test,
      
      // URI handling
      "org.apache.commons" % "commons-lang3" % "3.13.0"
    ),
    
    // Compiler options
    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-unchecked",
      "-Xfatal-warnings",
      "-language:higherKinds"
    )
  )
