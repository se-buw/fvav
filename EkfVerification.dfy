datatype Frame =
  Odom |
  BaseLink |
  Map |
  ImuLink

class EKFConfig
{
  var odomFrame: Frame
  var baseFrame: Frame
  var publishTf: bool

  constructor(o: Frame, b: Frame, tf: bool)
    ensures odomFrame == o
    ensures baseFrame == b
    ensures publishTf == tf
  {
    odomFrame := o;
    baseFrame := b;
    publishTf := tf;
  }
}

predicate ValidEkfTransform(e: EKFConfig)
  reads e
{
  e.odomFrame == Odom &&
  e.baseFrame == BaseLink &&
  e.publishTf == true
}

method VerifyEkfOdom()
{
  var ekf := new EKFConfig(Odom, BaseLink, true);

  assert ekf.odomFrame == Odom;
  assert ekf.baseFrame == BaseLink;
  assert ekf.publishTf == true;
  assert ValidEkfTransform(ekf);
}
