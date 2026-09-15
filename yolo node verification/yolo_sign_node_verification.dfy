// Define the strictly mapped commands
datatype Command = Left | Right | Stop | Straight | UTurn
datatype Option<T> = None | Some(value: T)
datatype Box = Box(conf: real, name: string)


class YoloNode { 

    // ==========================================
    // R1: Confidence Threshold Validation
    // ==========================================
    method GetBestDetection(boxes: seq<Box>, conf_thres: real) returns (found: bool, best_conf: real, best_name: string)
        requires conf_thres >= 0.0
        // VERIFICATION: If found, the confidence meets the threshold and matches a box from the input
        ensures found ==> best_conf >= conf_thres && (exists b :: b in boxes && b.conf == best_conf && b.name == best_name)
        // VERIFICATION: If not found, absolutely all boxes were below the threshold
        ensures !found ==> (forall b :: b in boxes ==> b.conf < conf_thres)
    {
        found := false;
        best_conf := 0.0;
        best_name := "";
        var i := 0;

        while i < |boxes|
            // Loop Invariants prove the conditions hold at every step of iteration
            invariant 0 <= i <= |boxes|
            invariant found ==> best_conf >= conf_thres && (exists b :: b in boxes[..i] && b.conf == best_conf && b.name == best_name)
            invariant !found ==> (forall b :: b in boxes[..i] ==> b.conf < conf_thres)
        {
            var b := boxes[i];
            if b.conf >= conf_thres {
                if !found || b.conf > best_conf {
                    found := true;
                    best_conf := b.conf;
                    best_name := b.name;
                }
            }
            i := i + 1;
        }
    }

    // ==========================================
    // R2: Mapped Classes
    // ==========================================
    static function ClassToCmd(c: string): Option<Command>
        // VERIFICATION: Strictly restricts output to the mapped set, or returns None.
        ensures ClassToCmd(c).Some? ==> ClassToCmd(c).value in {Left, Right, Stop, Straight, UTurn}
    {
        if c == "left" then Some(Left)
        else if c == "right" then Some(Right)
        else if c == "stop" then Some(Stop)
        else if c == "straight" then Some(Straight)
        else if c == "u_turn" then Some(UTurn)
        else None 
    }

}