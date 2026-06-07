datatype Option<T> = None | Some(value: T)

predicate HasSubstring(s: string, sub: string)
{
  exists i {:trigger s[i .. i + |sub|]} :: 0 <= i <= |s| - |sub| &&
               s[i .. i + |sub|] == sub
}


method ClassToCmd(classname: string) returns (result: Option<string>)
  ensures result == None ==>
    !HasSubstring(classname, "left")     &&
    !HasSubstring(classname, "right")    &&
    !HasSubstring(classname, "stop")     &&
    !HasSubstring(classname, "straight") &&
    !(HasSubstring(classname, "u") && HasSubstring(classname, "turn"))

  ensures result != None ==>
    result == Some("LEFT")     ||
    result == Some("RIGHT")    ||
    result == Some("STOP")     ||
    result == Some("STRAIGHT") ||
    result == Some("U_TURN")

  ensures result == Some("LEFT")     ==> HasSubstring(classname, "left")
  ensures result == Some("RIGHT")    ==> HasSubstring(classname, "right")
  ensures result == Some("STOP")     ==> HasSubstring(classname, "stop")
  ensures result == Some("STRAIGHT") ==> HasSubstring(classname, "straight")
  ensures result == Some("U_TURN")   ==>
    HasSubstring(classname, "u") && HasSubstring(classname, "turn")
{
  var c := classname;

  if HasSubstring(c, "left")     { return Some("LEFT"); }
  if HasSubstring(c, "right")    { return Some("RIGHT"); }
  if HasSubstring(c, "stop")     { return Some("STOP"); }
  if HasSubstring(c, "straight") { return Some("STRAIGHT"); }
  if HasSubstring(c, "u") && HasSubstring(c, "turn") { return Some("U_TURN"); }

  return None;
}
