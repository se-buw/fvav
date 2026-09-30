datatype Topic =
  CmdVelSafe |
  CmdVelNav |
  CmdVelJoy

// Defines the topic used as input to the Ackermann controller.
// In the current system configuration, the controller receives
// commands from the safety-filtered topic /cmd_vel_safe.
function ControllerInput(): Topic
{
  CmdVelSafe
}

// Formal safety property:
// The Ackermann controller must receive commands only from
// the safety-filtered topic (CmdVelSafe).
predicate ControllerUsesSafeTopic()
{
  ControllerInput() == CmdVelSafe
}

// Verification method:
// Dafny proves that the controller input satisfies the
// ControllerUsesSafeTopic safety property.
// The postcondition ensures that the controller always
// uses the safety-filtered command topic.
method VerifyControllerUsesSafeTopic()
  ensures ControllerUsesSafeTopic()
{
}