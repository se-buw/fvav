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