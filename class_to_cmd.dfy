// class_to_cmd.dfy
// Formal verification of YoloSignNode.class_to_cmd(classname).
// Python source: yolo_node.py lines 180-195.
//
// Assumption: input c is already strip().lower() normalised.
// "" represents Python's None (unmapped class).

include "common.dfy"

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
