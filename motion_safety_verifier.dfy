datatype MotionSource =
  Joystick |
  Tracker |
  Direction |
  Navigation |
  Nav2

function Priority(s: MotionSource): int
{
  match s
  case Joystick => 100
  case Tracker => 20
  case Direction => 15
  case Navigation => 10
  case Nav2 => 5
}

// Safety requirement:
// Manual joystick commands must always have higher priority
// than autonomous navigation commands (Nav2).
predicate ManualOverrideSafety()
{
  Priority(Joystick) > Priority(Nav2)
}

// Dafny verifies that the safety requirement is satisfied.
// The postcondition ensures that ManualOverrideSafety holds.
method VerifyManualOverrideSafety()
  ensures ManualOverrideSafety()
{
}