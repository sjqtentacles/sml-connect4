(* test.sml — tests for sml-connect4.
   Reference vectors (all hand-verified):
   - 7 legal columns on empty board
   - drop returns NONE on full column
   - vertical win (4 discs stacked)
   - horizontal win
   - diagonal win
   - draw (board full, no winner)
   - bestMove detects immediate win in 1
*)

structure Tests =
struct
  open Harness

  fun runAll () =
    let
      val () = section "empty board"
      val s0 = Connect4.empty
      val () = checkInt "7 legal cols" (7, List.length (Connect4.legalCols s0))
      val () = check "not terminal" (not (Connect4.terminal s0))
      val () = check "no winner" (Connect4.winner s0 = NONE)
      val () = check "not draw" (not (Connect4.isDraw s0))
      val () = checkInt "toMove = Red" (Connect4.Red, Connect4.toMove s0)
      val () = checkInt "ROWS=6" (6, Connect4.ROWS)
      val () = checkInt "COLS=7" (7, Connect4.COLS)

      val () = section "drop"
      val s1 = valOf (Connect4.drop s0 0)   (* Red drops col 0 *)
      val () = checkInt "height col 0 = 1" (1, Connect4.height s1 0)
      val () = checkInt "height col 1 = 0" (0, Connect4.height s1 1)
      val () = checkInt "get row0 col0 = Red" (Connect4.Red, Connect4.get s1 0 0)
      val () = checkInt "toMove = Yellow" (Connect4.Yellow, Connect4.toMove s1)
      val () = checkInt "6 legal cols still" (7, List.length (Connect4.legalCols s1))

      val () = section "full column"
      fun fillCol s c =
        case Connect4.drop s c of
          NONE => s
        | SOME s' => fillCol s' c
      val sfull = fillCol s0 0
      val () = checkInt "full height = ROWS" (Connect4.ROWS, Connect4.height sfull 0)
      val () = check "drop on full = NONE" (not (isSome (Connect4.drop sfull 0)))
      val () = checkInt "6 legal cols" (6, List.length (Connect4.legalCols sfull))

      val () = section "vertical win (4 in col)"
      (* Red plays col 0 four times, Yellow plays col 1 each time *)
      fun play (s, mvs) = List.foldl (fn (c, s') => valOf (Connect4.drop s' c)) s mvs
      val sv = play (s0, [0,1, 0,1, 0,1, 0])  (* Red wins col 0 *)
      val () = check "vertical win Red" (Connect4.winner sv = SOME Connect4.Red)
      val () = check "terminal after win" (Connect4.terminal sv)
      val () = check "no legal cols after win" (Connect4.legalCols sv = [])

      val () = section "horizontal win"
      (* Red plays cols 0,1,2,3; Yellow plays col 5 each time *)
      val sh = play (s0, [0,5, 1,5, 2,5, 3])
      val () = check "horizontal win Red" (Connect4.winner sh = SOME Connect4.Red)

      val () = section "diagonal win (/ direction)"
      (* Build: Red at (0,0)(1,1)(2,2)(3,3) — ascending diagonal *)
      (* R Y moves:
         col0: R  col0:Y  col1:R  col1:Y col1:R
         col2: R  col2:Y col2:Y col2:R  ... *)
      (* Simpler: staircase *)
      (* step-by-step to get Red on the main diagonal: *)
      (* After R:c0, Y:c1, R:c1, Y:c2, R:c2, Y:c2, R:c3, Y:c3, Y:c3, R:c3 *)
      (* heights: c0=1,c1=2,c2=3,c3=4? No... *)
      (* Use the known sequence: *)
      val sd = play (s0, [0, 1, 1, 2, 2, 3, 2, 3, 3, 5, 3])
      (* Let's verify: track heights
         c0:R1  c1:Y1  c1:R2  c2:Y1  c2:R2  c3:Y1  c2:R3  c3:Y2  c3:R3? wait
         Move 1: R c0  heights:[1,0,0,0,...] R at (0,0)
         Move 2: Y c1  heights:[1,1,0,0,...] Y at (0,1)
         Move 3: R c1  heights:[1,2,0,0,...] R at (1,1)
         Move 4: Y c2  heights:[1,2,1,0,...] Y at (0,2)
         Move 5: R c2  heights:[1,2,2,0,...] R at (1,2)
         Move 6: Y c3  heights:[1,2,2,1,...] Y at (0,3)
         Move 7: R c2  heights:[1,2,3,1,...] R at (2,2)
         Move 8: Y c3  heights:[1,2,3,2,...] Y at (1,3)
         Move 9: R c3  heights:[1,2,3,3,...] R at (2,3)
         Move 10: Y c5  heights:[1,2,3,3,0,1,...] Y at (0,5)
         Move 11: R c3  heights:[1,2,3,4,...] R at (3,3)
         Red pieces: (0,0)(1,1)(2,2)(3,3) => ascending diagonal WIN *)
      val () = check "diagonal win Red" (Connect4.winner sd = SOME Connect4.Red)

      val () = section "bestMove detects win-in-1"
      (* Red has 3 in a row horizontally; playing col 3 wins *)
      val sw1 = play (s0, [0,5, 1,5, 2,5])  (* Red: c0,c1,c2 row 0; Yellow: c5 *)
      val bm = Connect4.bestMove 4 sw1
      val () = check "bestMove = col 3 (win)" (bm = SOME 3)

      val () = section "toString"
      val () = check "toString non-empty" (String.size (Connect4.toString s0) > 0)
      val () = check "toString has rows" (String.isSubstring "." (Connect4.toString s0))
    in
      Harness.run ()
    end

  val run = runAll
end
