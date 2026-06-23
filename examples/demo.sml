(* examples/demo.sml — sml-connect4 demonstration *)

fun play (s, mvs) = List.foldl (fn (c, s') => valOf (Connect4.drop s' c)) s mvs

val () =
  let
    val () = print "=== Connect Four ===\n"
    val s0 = Connect4.empty
    val () = print ("Empty board:\n" ^ Connect4.toString s0)

    (* Vertical win: Red drops col 0 four times; Yellow drops col 1 *)
    val sv = play (s0, [0,1, 0,1, 0,1, 0])
    val () = print "\nVertical win (Red plays col 0 x4, Yellow col 1 x3):\n"
    val () = print (Connect4.toString sv)
    val wr = case Connect4.winner sv of
               SOME 1 => "Red" | SOME _ => "Yellow" | NONE => "None"
    val () = print ("Winner: " ^ wr ^ "\n")

    (* Horizontal win: Red plays cols 0-3, Yellow plays col 5 *)
    val sh = play (s0, [0,5, 1,5, 2,5, 3])
    val () = print "\nHorizontal win (Red plays cols 0-3):\n"
    val () = print (Connect4.toString sh)
    val wh = case Connect4.winner sh of
               SOME 1 => "Red" | SOME _ => "Yellow" | NONE => "None"
    val () = print ("Winner: " ^ wh ^ "\n")

    (* Win-in-1 detection *)
    val () = print "\n=== Win-in-1 detection ===\n"
    val sw = play (s0, [0,5, 1,5, 2,5])  (* Red has 3 in a row *)
    val () = print (Connect4.toString sw)
    val bm = case Connect4.bestMove 4 sw of
               NONE => "none" | SOME c => Int.toString c
    val () = print ("Best move for Red: col " ^ bm ^ " (completes 4 in a row)\n")
  in () end
