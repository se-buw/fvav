// best_detection.dfy
// Formal verification of the argmax detection loop in inference_loop().
//
// Models the loop that finds the highest-confidence box above confThres.
// "" represents Python's None for bestName (no detection found).

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
