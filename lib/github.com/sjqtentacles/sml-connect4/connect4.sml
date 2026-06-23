(* connect4.sml

   Pure Standard ML Connect Four engine.
   Standard 6×7 board.  Pieces drop to the lowest empty row in a column.
   Win = 4 in a row (horiz, vert, or diagonal).

   Representation: two int arrays of length COLS (one per player), where
   each element is a bitmask of occupied rows (bit r = row r from bottom).
*)

structure Connect4 :> CONNECT4 =
struct

  val ROWS = 6
  val COLS = 7
  val Red    = 1
  val Yellow = 2

  type state =
    { masks : int array array   (* .(0)=Red, .(1)=Yellow, each length COLS *)
    , turn  : int
    , total : int
    }

  val empty : state =
    { masks = Array.fromList [Array.array (COLS, 0), Array.array (COLS, 0)]
    , turn  = Red
    , total = 0
    }

  fun toMove (st : state) = #turn st

  fun colMask (st : state) p c =
    Array.sub (Array.sub (#masks st, p - 1), c)

  fun height (st : state) c =
    let
      val m = Word.orb (Word.fromInt (colMask st Red c),
                        Word.fromInt (colMask st Yellow c))
      fun count w acc =
        if w = 0w0 then acc
        else count (Word.>> (w, 0w1)) (acc + Word.toInt (Word.andb (w, 0w1)))
    in count m 0 end

  fun get (st : state) row col =
    let val bit = Word.<< (0w1, Word.fromInt row)
        val m0  = Word.fromInt (colMask st Red col)
        val m1  = Word.fromInt (colMask st Yellow col)
    in
      if Word.andb (m0, bit) <> 0w0 then Red
      else if Word.andb (m1, bit) <> 0w0 then Yellow
      else 0
    end

  fun copyMasks (masks : int array array) =
    Array.tabulate (2, fn p =>
      Array.tabulate (COLS, fn c => Array.sub (Array.sub (masks, p), c)))

  fun hasWon (st : state) p =
    let
      val pm = Array.sub (#masks st, p - 1)
      fun cell r c =
        if r < 0 orelse r >= ROWS orelse c < 0 orelse c >= COLS then false
        else
          let val bit = Word.<< (0w1, Word.fromInt r)
          in  Word.andb (Word.fromInt (Array.sub (pm, c)), bit) <> 0w0
          end
      fun run4 r c dr dc =
        cell r c andalso cell (r+dr) (c+dc)
        andalso cell (r+2*dr) (c+2*dc) andalso cell (r+3*dr) (c+3*dc)
      fun check r c =
        run4 r c 0 1 orelse run4 r c 1 0
        orelse run4 r c 1 1 orelse run4 r c 1 ~1
      fun checkAll r c =
        if r >= ROWS then false
        else if c >= COLS then checkAll (r+1) 0
        else if check r c then true
        else checkAll r (c+1)
    in checkAll 0 0 end

  fun winner (st : state) =
    if hasWon st Red then SOME Red
    else if hasWon st Yellow then SOME Yellow
    else NONE

  fun isDraw (st : state) =
    winner st = NONE andalso #total st = ROWS * COLS

  fun terminal (st : state) = winner st <> NONE orelse isDraw st

  fun legalCols (st : state) =
    if terminal st then []
    else List.filter (fn c => height st c < ROWS)
                     (List.tabulate (COLS, fn i => i))

  fun drop (st : state) col =
    if col < 0 orelse col >= COLS then NONE
    else
      let val h = height st col
      in  if h >= ROWS then NONE
          else
            let val newMasks = copyMasks (#masks st)
                val p = #turn st - 1
                val old = Array.sub (Array.sub (newMasks, p), col)
                val bit = Word.toInt (Word.<< (0w1, Word.fromInt h))
                val () = Array.update (Array.sub (newMasks, p), col, old + bit)
            in  SOME { masks = newMasks
                      , turn  = if #turn st = Red then Yellow else Red
                      , total = #total st + 1
                      }
            end
      end

  fun toString (st : state) =
    let
      fun cellChar r c =
        case get st r c of 1 => "R" | 2 => "Y" | _ => "."
      fun rowStr r =
        String.concat (List.map (cellChar r) (List.tabulate (COLS, fn i => i)))
      val rows = List.map rowStr (List.rev (List.tabulate (ROWS, fn i => i)))
    in
      "0123456\n" ^ String.concatWith "\n" rows ^ "\n"
    end

  (* ---- GAME interface ---- *)
  local
    structure C4G : GAME =
    struct
      type state = { masks : int array array, turn : int, total : int }
      type move  = int
      fun hash (st : state) =
        let val h = ref (#turn st)
        in  Array.app (fn col =>
              Array.app (fn v => h := !h * 37 + v) col) (#masks st) ; !h
        end
      fun moves (st : state) = legalCols st
      fun apply (st : state) mv = valOf (drop st mv)
      fun terminal (st : state) = winner st <> NONE orelse isDraw st
      fun eval (st : state) =
        case winner st of SOME _ => ~1000000 | NONE => 0
    end
    structure S = GameTreeSearch(C4G)
  in
    fun bestMove depth (st : state) =
      if terminal st then NONE
      else S.bestMove depth st
  end

end
