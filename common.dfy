// common.dfy
// Shared predicates used across yolo_node verifications.
// Each include "common.dfy" in sibling files.

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
