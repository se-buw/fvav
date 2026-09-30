// Obstacle Safety Verification
//
// Safety requirement:
// The robot must not be considered safe when it is moving forward
// and an obstacle is closer than the configured safety threshold.

predicate ObstacleSafety(
    speed: real,
    distance: real,
    threshold: real
)
{
    !(speed > 0.05 && distance < threshold)
}


// Verification method:
//
// If ObstacleSafety is true, then the robot is not simultaneously
// moving forward and too close to an obstacle.
method VerifyObstacleSafety(
    speed: real,
    distance: real,
    threshold: real
)
    requires threshold > 0.0
    requires ObstacleSafety(speed, distance, threshold)
    ensures !(speed > 0.05 && distance < threshold)
{
}