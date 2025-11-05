# HTC Digital Twin Language (HTCDL) - Core Library

[![Scala Version](https://img.shields.io/badge/scala-3.3.6-red.svg)](https://www.scala-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

A comprehensive Scala 3 library for parsing, validating, and code generation from HTCDL (HTC Digital Twin Language) models.

## 🚀 Overview

HTCDL Core Library is the reference implementation and "compiler" for the HTC Digital Twin Language, providing:

- **Complete Parser**: JSON-LD to Scala case classes with Circe
- **Robust Validation**: 17+ validation rules for semantic correctness
- **Actor Code Generation**: Automatic generation of HTC simulator-compatible actors
- **Fluent Builder API**: Programmatic model creation with type safety
- **Runtime Support**: Infrastructure for HTCDL-generated actors

This library serves as the foundation for the HTC simulator ecosystem and digital twin applications.

## 📦 Features

- **Robust Parsing**: JSON to Scala case classes conversion using Circe
- **Comprehensive Validation**: Reference, structure and semantic verification
- **Intuitive API**: Simple interface for use in other projects
- **Model Analysis**: Statistics and unused element detection
- **Builder Pattern**: Programmatic HTCDL model creation
- **Extensibility**: Modular architecture for future extensions

## 🏗️ Architecture

```
com.htc.dtl/
├── model/           # Case classes representing the HTCDL model
├── parser/          # Main parser and utilities
├── validation/      # Validation system with business rules
└── HtcDtl.scala    # Main API
```

## 📖 Basic Usage

### Parsing a model

```scala
import com.htc.dtl.HtcDtl

// From file
val result = HtcDtl.parseFile("model.htcdl.json")

result match
  case Right(model) => 
    println(s"Model ${model.displayName} loaded successfully!")
    println(s"States: ${model.stateMachine.map(_.states.size).getOrElse(0)}")
  case Left(error) => 
    println(s"Error loading model: $error")

// From JSON string
val jsonString = """{ "@context": "dtmi:htc:context;1", ... }"""
val model = HtcDtl.parse(jsonString).getOrThrow
```

### Programmatic model creation

```scala
import com.htc.dtl.{HtcModelBuilder, HtcUtils}
import com.htc.dtl.model.*

val model = HtcModelBuilder("dtmi:htc:robot;1", "Smart Robot", "An intelligent robot")
  .withVersion("1.0.0", Some("Initial version"))
  .addProperty(HtcUtils.property("batteryLevel", "double", unit = Some("percent")))
  .addTelemetry(HtcUtils.telemetry("position", "dtmi:geo:position;1"))
  .addCommand(HtcUtils.command("move", IntentType.Control, ExecutionMode.Async))
  .addEvent(HtcUtils.event("batteryLow"))
  .withStateMachine(StateMachine(
    initialState = "Idle",
    states = List(
      HtcUtils.state("Idle"),
      HtcUtils.state("Moving")
    ),
    transitions = List(
      HtcUtils.transitionOnCommand("Idle", "Moving", "move")
    )
  ))
  .addRule(HtcUtils.rule("BatteryWarning", "batteryLevel < 10", "batteryLow"))
  .build()

// Validate the model
val validationResult = HtcDtl.validate(model)
validationResult match
  case Right(validModel) => println("Valid model!")
  case Left(errors) => errors.foreach(println)
```

### Model analysis

```scala
// Get statistics
val stats = HtcDtl.analyze(model)
println(s"Properties: ${stats.propertyCount}")
println(s"Commands: ${stats.commandCount}")
println(s"Has state machine: ${stats.hasStateMachine}")

// Find unused elements
val unused = HtcDtl.findUnused(model)
if unused.unusedEvents.nonEmpty then
  println(s"Unused events: ${unused.unusedEvents.mkString(", ")}")
```

### Serialization

```scala
// Convert to JSON
val json = HtcDtl.toJson(model)
println(json)

// Save to file
import com.htc.dtl.parser.ModelSerializer
ModelSerializer.writeToFile(model, "output.htcdl.json")
```

## 🔍 Validation System

The library includes a robust validation system that checks:

### Basic Structure
- ✅ Valid JSON-LD context
- ✅ Well-formed DTMI
- ✅ Required fields present
- ✅ Correct data types

### References
- ✅ Commands referenced in transitions exist
- ✅ Referenced events exist
- ✅ Referenced states exist
- ✅ Referenced schemas are defined

### Semantics
- ✅ Unique names within each collection
- ✅ Reachable states in state machine
- ✅ Valid triggers in transitions
- ✅ Command completion events exist

### Validation Example

```scala
val errors = List(
  ValidationError.InvalidReference("Trigger", "invalidCommand", "Command", "invalidCommand"),
  ValidationError.DuplicateName("Property", "duplicatedName"),
  ValidationError.MissingRequiredField("HtcModel", "displayName")
)

// Automatic error formatting
errors.foreach(error => println(ErrorFormatter.formatValidationError(error)))
```

## 🧪 Testing

```bash
sbt test
```

Tests cover:
- Parsing of valid and invalid models
- All validation rules
- Builder pattern
- Serialization/deserialization
- Model analysis

## 📊 Model Metrics

The library offers automatic analysis:

```scala
case class ModelStatistics(
  propertyCount: Int,
  telemetryCount: Int,
  commandCount: Int,
  eventCount: Int,
  relationshipCount: Int,
  stateCount: Int,
  transitionCount: Int,
  ruleCount: Int,
  goalCount: Int,
  aiModelCount: Int,
  hasStateMachine: Boolean,
  hasPhysics: Boolean
)
```

## � Installation

### Maven Central (Coming Soon)

```scala
// build.sbt
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

### Local Installation (Development)

```bash
git clone https://github.com/fwrock/htc-dl.git
cd htc-dl
sbt publishLocal
```

Then in your project:

```scala
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

## � Actor Code Generation

Generate HTC simulator-compatible actors from HTCDL models:

```scala
import com.htc.dtl.codegen.HtcActorGenerator

// Generate actor code
val actorCode = HtcActorGenerator.generateActor(
  model,
  packageName = "org.example.generated"
)

// Or save directly to file
HtcActorGenerator.generateActorFile(
  "models/thermostat.htcdl.json",
  "target/generated-sources/SmartThermostatActor.scala"
)
```

Generated actors include:
- ✅ State machine implementation
- ✅ Command handlers
- ✅ Event emission
- ✅ Telemetry management
- ✅ Rules engine integration
- ✅ Full compatibility with HTC simulator's `BaseActor`

## 🎯 Use Cases

- **Digital Twin Modeling**: Define behavior of IoT devices, vehicles, sensors
- **Simulation**: Generate actors for distributed simulations
- **Code Generation**: Automatic creation of type-safe digital twin implementations
- **Validation**: Ensure model correctness before deployment
- **Documentation**: Analyze and document digital twin architectures

## 📊 Project Statistics

- **Lines of Code**: ~1,500 Scala
- **Test Coverage**: 15 tests (100% passing)
- **Validation Rules**: 17+ semantic checks
- **Examples**: 2 complete HTCDL models included

## 📝 Examples

Complete examples available:
- `src/main/resources/examples/car-model.htcdl.json` - Autonomous vehicle
- `src/main/scala/com/htc/dtl/integration/HtcIntegrationExample.scala` - Complete workflow

## 📚 Documentation

- **[Publishing Guide](PUBLISHING_GUIDE.md)** - How to publish this library
- **[Quick Start](QUICK_START.md)** - Get started in 5 minutes
- **[Project Summary](PROJECT_SUMMARY.md)** - Complete project documentation
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** - Technical details
- **[Changelog](CHANGELOG.md)** - Version history

## 🤝 Contributing

Contributions are welcome! Please ensure:
- All tests pass (`sbt test`)
- Code follows Scala 3 best practices
- New features include tests
- Documentation is updated

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Repository**: https://github.com/fwrock/htc-dl
- **Issues**: https://github.com/fwrock/htc-dl/issues
- **Scaladex**: https://index.scala-lang.org/fwrock/htc-dl (after publication)

---

**HTC Digital Twin Language Core Library** - Transforming JSON descriptions into intelligent digital twin systems 🚀
