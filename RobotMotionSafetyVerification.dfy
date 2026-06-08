datatype MotionSource =
  Joystick |
  Tracker |
  Direction |
  SafeCommand |
  Nav2

function Priority(s: MotionSource): int {
  match s
  case Joystick => 100
  case Tracker => 20
  case Direction => 15
  case SafeCommand => 10
  case Nav2 => 5
}

predicate SafePriorityOrder()
{
  Priority(Joystick) > Priority(Tracker) &&
  Priority(Tracker) > Priority(Direction) &&
  Priority(Direction) > Priority(SafeCommand) &&
  Priority(SafeCommand) > Priority(Nav2)
}

class MotionControlPipeline
{
  var hasTwistMux: bool
  var hasAckermannController: bool
  var hasSafeCommandTopic: bool
  var hasRobotLaunch: bool
  var hasSimulationLaunch: bool

  constructor(twist: bool, controller: bool, safeTopic: bool, robotLaunch: bool, simLaunch: bool)
    ensures hasTwistMux == twist
    ensures hasAckermannController == controller
    ensures hasSafeCommandTopic == safeTopic
    ensures hasRobotLaunch == robotLaunch
    ensures hasSimulationLaunch == simLaunch
  {
    hasTwistMux := twist;
    hasAckermannController := controller;
    hasSafeCommandTopic := safeTopic;
    hasRobotLaunch := robotLaunch;
    hasSimulationLaunch := simLaunch;
  }
}

predicate ValidMotionSafetyPipeline(p: MotionControlPipeline)
  reads p
{
  SafePriorityOrder() &&
  p.hasTwistMux &&
  p.hasAckermannController &&
  p.hasSafeCommandTopic &&
  p.hasRobotLaunch &&
  p.hasSimulationLaunch
}

method VerifyRobotMotionSafety()
{
  var pipeline := new MotionControlPipeline(true, true, true, true, true);

  assert SafePriorityOrder();
  assert pipeline.hasTwistMux;
  assert pipeline.hasAckermannController;
  assert pipeline.hasSafeCommandTopic;
  assert pipeline.hasRobotLaunch;
  assert pipeline.hasSimulationLaunch;

  assert ValidMotionSafetyPipeline(pipeline);
}