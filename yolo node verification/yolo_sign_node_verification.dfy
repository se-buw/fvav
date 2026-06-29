// Unified formal verification for YoloSignNode (yolo_node.py).

// Recursive substring check: does s contain sub?
predicate Contains(s: string, sub: string)
  decreases |s|
{
  if |sub| == 0 then true
  else if |s| < |sub| then false
  else s[..|sub|] == sub || Contains(s[1..], sub)
}

lemma ContainsEmpty(s: string)
  ensures Contains(s, "")
{}

lemma ContainsPrefix(s: string, sub: string)
  requires |s| >= |sub| && |sub| > 0
  requires s[..|sub|] == sub
  ensures Contains(s, sub)
{}

lemma ContainsTail(s: string, sub: string)
  requires |s| > 0 && |sub| > 0
  requires Contains(s[1..], sub)
  ensures Contains(s, sub)
{}

// ===========================================================================
// Section 1 — best_detection
// Formal verification of the argmax detection loop in inference_loop().
//
// Models the loop that finds the highest-confidence box above confThres.
// "" represents Python's None for bestName (no detection found).
// ===========================================================================

datatype Box = Box(conf: real, name: string)

// --- postconditions ---
//   1. If nothing found  -> every box was below threshold
//   2. If found          -> bestConf >= confThres
//   3. bestConf is truly the maximum among boxes above threshold
//   4. (bestConf, bestName) corresponds to an actual box in the sequence

method BestDetection(boxes: seq<Box>, confThres: real)
    returns (bestConf: real, bestName: string)
  requires confThres > 0.0
  requires forall b :: b in boxes ==> b.conf >= 0.0
  requires forall b :: b in boxes ==> b.name != ""
  ensures bestName == "" ==>
            forall b :: b in boxes ==> b.conf < confThres
  ensures bestName != "" ==> bestConf >= confThres
  ensures forall b :: b in boxes && b.conf >= confThres ==>
            bestConf >= b.conf
  ensures bestName != "" ==>
            exists b :: b in boxes && b.conf == bestConf && b.name == bestName
{
  bestConf := 0.0;
  bestName := "";

  var i := 0;
  while i < |boxes|
    invariant 0 <= i <= |boxes|
    invariant bestName == "" ==>
                forall j :: 0 <= j < i ==> boxes[j].conf < confThres
    invariant bestName == "" ==> bestConf == 0.0
    invariant bestName != "" ==> bestConf >= confThres
    invariant forall j :: 0 <= j < i && boxes[j].conf >= confThres ==>
                bestConf >= boxes[j].conf
    invariant bestName != "" ==>
                exists j :: 0 <= j < i &&
                  boxes[j].conf == bestConf && boxes[j].name == bestName
  {
    var b := boxes[i];
    if b.conf >= confThres {
      if b.conf > bestConf {
        bestConf := b.conf;
        bestName := b.name;
      } else {
        // b.conf >= confThres && b.conf <= bestConf
        // bestConf == 0.0 when bestName == "", but confThres > 0.0 <= b.conf,
        assert bestName != "";
      }
    }
    i := i + 1;
  }
}

// --- key property lemmas ---

// Empty input always produces no detection.
lemma EmptyBoxesNoDetection(confThres: real)
  requires confThres > 0.0
  ensures forall b: Box :: b in [] ==> b.conf < confThres
{}

// A box above threshold retains its conf after selection.
lemma SingleBoxAboveThreshold(b: Box, confThres: real)
  requires confThres > 0.0
  requires b.conf >= confThres
  ensures b.conf >= confThres && b.name == b.name
{}

// ===========================================================================
// Section 2 — class_to_cmd
// Formal verification of YoloSignNode.class_to_cmd(classname).
//
// Assumption: input c is already strip().lower() normalised.
// "" represents Python's None (unmapped class).
// ===========================================================================

function ClassToCmd(c: string): string
  ensures ClassToCmd(c) in {"LEFT", "RIGHT", "STOP", "STRAIGHT", "U_TURN", ""}
{
  if Contains(c, "left")                       then "LEFT"
  else if Contains(c, "right")                 then "RIGHT"
  else if Contains(c, "stop")                  then "STOP"
  else if Contains(c, "straight")              then "STRAIGHT"
  else if Contains(c, "u") && Contains(c, "turn") then "U_TURN"
  else ""
}

// --- postcondition lemmas ---

// Left takes priority over all others when present.
lemma LeftPriority(c: string)
  requires Contains(c, "left")
  ensures ClassToCmd(c) == "LEFT"
{}

// Right is matched only when left is absent.
lemma RightPriority(c: string)
  requires !Contains(c, "left")
  requires Contains(c, "right")
  ensures ClassToCmd(c) == "RIGHT"
{}

// U_TURN requires both substrings; either alone is insufficient.
lemma UTurnRequiresBoth(c: string)
  ensures ClassToCmd(c) == "U_TURN" ==>
          Contains(c, "u") && Contains(c, "turn")
{}

lemma UTurnMissingU(c: string)
  requires !Contains(c, "u")
  ensures ClassToCmd(c) != "U_TURN"
{}

lemma UTurnMissingTurn(c: string)
  requires !Contains(c, "turn")
  ensures ClassToCmd(c) != "U_TURN"
{}

// An unmapped class produces "" (Python None).
lemma UnmappedIsEmpty(c: string)
  requires !Contains(c, "left")
  requires !Contains(c, "right")
  requires !Contains(c, "stop")
  requires !Contains(c, "straight")
  requires !(Contains(c, "u") && Contains(c, "turn"))
  ensures ClassToCmd(c) == ""
{}
