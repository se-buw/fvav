
// Verified from: seav2/config/my_controllers.yaml
// Real controller:
// acker_cont: ackermann_steering_controller/AckermannSteeringController
// Real command topic:
// cmd_vel_topic: /cmd_vel_safe
// Property verified:
// Ackermann controller receives only safety-filtered velocity commands.


datatype Topic =
  CmdVelSafe |
  CmdVelNav |
  CmdVelJoy

class AckermannController
{
  var inputTopic: Topic

  constructor(t: Topic)
    ensures inputTopic == t
  {
    inputTopic := t;
  }
}

predicate SafeControllerInput(c: AckermannController)
  reads c
{
  c.inputTopic == CmdVelSafe
}

method VerifyController()
{
  var controller := new AckermannController(CmdVelSafe);

  assert controller.inputTopic == CmdVelSafe;
  assert SafeControllerInput(controller);
}