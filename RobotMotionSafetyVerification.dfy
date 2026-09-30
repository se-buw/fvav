datatype MotionSource =
  Joystick |
  Tracker |
  Direction |
  Navigation |
  Nav2

datatype Topic =
  CmdVelSafe |
  CmdVelNav |
  CmdVelJoy

// Defines the priority assigned to each motion command source.
// These values correspond to the twist_mux configuration used
// in the ROS2 motion control pipeline.
function Priority(s: MotionSource): int
{
  match s
  case Joystick => 100
  case Tracker => 20
  case Direction => 15
  case Navigation => 10
  case Nav2 => 5
}

// Defines the topic used as input to the Ackermann controller.
// The controller should only receive commands from the
// safety-filtered topic /cmd_vel_safe.
function ControllerInput(): Topic
{
  CmdVelSafe
}

// Formal safety property:
// Manual joystick commands must always have higher priority
// than autonomous navigation commands (Nav2).
// This ensures that a human operator can immediately override
// autonomous behaviour when necessary.
predicate ManualOverrideSafety()
{
  Priority(Joystick) > Priority(Nav2)
}

// Formal safety property:
// The Ackermann controller must receive commands only from
// the safety-filtered topic CmdVelSafe.
predicate ControllerUsesSafeTopic()
{
  ControllerInput() == CmdVelSafe
}

// Overall motion safety property:
// 1. Manual control can override autonomous navigation.
// 2. The controller receives only safety-filtered commands.
//
// Together, these properties represent the safety requirements
// of the robot motion-control pipeline.
predicate MotionSafetyPipeline()
{
  ManualOverrideSafety() &&
  ControllerUsesSafeTopic()
}

// Verification method:
// Dafny proves that the complete motion safety pipeline
// satisfies all specified safety requirements.
// The postcondition ensures that MotionSafetyPipeline holds.
method VerifyMotionSafetyPipeline()
  ensures MotionSafetyPipeline()
{
}
