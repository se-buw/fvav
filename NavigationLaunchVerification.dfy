class NavigationLaunch
{
  var hasControllerServer: bool
  var hasPlannerServer: bool
  var hasBehaviorServer: bool
  var hasBtNavigator: bool
  var hasWaypointFollower: bool
  var hasVelocitySmoother: bool
  var hasLifecycleManager: bool

  constructor(controller: bool, planner: bool, behavior: bool, bt: bool, waypoint: bool, smoother: bool, lifecycle: bool)
    ensures hasControllerServer == controller
    ensures hasPlannerServer == planner
    ensures hasBehaviorServer == behavior
    ensures hasBtNavigator == bt
    ensures hasWaypointFollower == waypoint
    ensures hasVelocitySmoother == smoother
    ensures hasLifecycleManager == lifecycle
  {
    hasControllerServer := controller;
    hasPlannerServer := planner;
    hasBehaviorServer := behavior;
    hasBtNavigator := bt;
    hasWaypointFollower := waypoint;
    hasVelocitySmoother := smoother;
    hasLifecycleManager := lifecycle;
  }
}

predicate ValidNavigationLaunch(n: NavigationLaunch)
  reads n
{
  n.hasControllerServer &&
  n.hasPlannerServer &&
  n.hasBehaviorServer &&
  n.hasBtNavigator &&
  n.hasWaypointFollower &&
  n.hasVelocitySmoother &&
  n.hasLifecycleManager
}

method VerifyNavigationLaunch()
{
  var nav := new NavigationLaunch(true, true, true, true, true, true, true);

  assert nav.hasControllerServer;
  assert nav.hasPlannerServer;
  assert nav.hasBehaviorServer;
  assert nav.hasBtNavigator;
  assert nav.hasWaypointFollower;
  assert nav.hasVelocitySmoother;
  assert nav.hasLifecycleManager;
  assert ValidNavigationLaunch(nav);
}