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