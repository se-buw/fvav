// Verified from: seav2/config/twist_mux.yaml
// Real priorities:
// joystick = 100
// tracker = 20
// direction = 15
// navigation = 10
// nav2 = 5
// Property verified:
// Manual joystick control has the highest priority.
// Nav2 autonomous control has the lowest priority.

datatype Topic =
  CmdVelNav |
  CmdVelSafe |
  CmdVelJoy |
  CmdVelTracker |
  CmdVelDirection

function Priority(t: Topic): int {
  match t
  case CmdVelNav => 5
  case CmdVelSafe => 10
  case CmdVelDirection => 15
  case CmdVelTracker => 20
  case CmdVelJoy => 100
}

predicate SafePriorityOrder()
{
  Priority(CmdVelJoy) > Priority(CmdVelTracker) &&
  Priority(CmdVelTracker) > Priority(CmdVelDirection) &&
  Priority(CmdVelDirection) > Priority(CmdVelSafe) &&
  Priority(CmdVelSafe) > Priority(CmdVelNav)
}

method VerifyTwistMux()
  ensures SafePriorityOrder()
{
}