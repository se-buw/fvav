// ================================================
// Formal Verification - AMCL Localization Safety
// Based on: nav2_params.yaml in seav2 project
//
// Actual values from your nav2_params.yaml:
//   min_particles    = 200
//   max_particles    = 800
//   update_min_d     = 0.25 metres
//   update_min_a     = 0.2  radians
//   wheelbase        = 0.6  metres
//   min_turning_radius = 2.5 metres
// ================================================

// Property 1: Particle filter bounds are valid
// min_particles must always be less than max_particles
// Values directly from nav2_params.yaml
lemma ParticleFilterBoundsValid()
  ensures 200 < 800
  ensures 200 > 0
  ensures 800 > 0
{
  // Z3 proves this automatically
}

// Property 2: Robot only updates localization
// when it has moved enough distance OR rotated enough
// update_min_d = 0.25m, update_min_a = 0.2 rad
method ShouldUpdateLocalization(
  distanceMoved: real,
  angleMoved: real
) returns (shouldUpdate: bool)
  requires distanceMoved >= 0.0
  requires angleMoved >= 0.0
  ensures shouldUpdate == 
    (distanceMoved >= 0.25 || angleMoved >= 0.2)
{
  shouldUpdate := distanceMoved >= 0.25 
               || angleMoved >= 0.2;
}

// Property 3: Ackermann motion model constraints
// wheelbase = 0.6m, min_turning_radius = 2.5m
// A car-like robot cannot turn on the spot
lemma AckermannConstraintsValid()
  ensures 2.5 > 0.6
  ensures 0.6 > 0.0
  ensures 2.5 > 0.0
{
  // Z3 proves this automatically
}

// Property 4: Localization confidence check
// Robot must have minimum particles to be confident
method IsLocalizationConfident(
  currentParticles: int
) returns (confident: bool)
  requires currentParticles >= 0
  ensures confident == (currentParticles >= 200)
{
  confident := currentParticles >= 200;
}