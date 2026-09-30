#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DAFNY=dafny

echo "Running Dafny verification..."

echo "1. Verifying motion_safety_verifier.dfy"
$DAFNY verify motion_safety_verifier.dfy

echo "2. Verifying ControllerVerification.dfy"
$DAFNY verify ControllerVerification.dfy

echo "3. Verifying RobotMotionSafetyVerification.dfy"
$DAFNY verify RobotMotionSafetyVerification.dfy

echo "4. Verifying ObstacleSafetyVerification.dfy"
$DAFNY verify ObstacleSafetyVerification.dfy

echo "All Dafny verification completed successfully."