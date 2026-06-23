(* connect4.sig

   Pure Standard ML Connect Four engine.

   Standard board: 6 rows × 7 columns. Players alternate dropping discs.
   A player wins by connecting 4 in a row (horizontal, vertical, or diagonal).

   Squares are indexed column-major from the bottom: column c, row r (0=bottom)
   → index c * ROWS + r. Pieces drop to the lowest empty row in a column.
*)

signature CONNECT4 =
sig
  val ROWS : int   (* 6 *)
  val COLS : int   (* 7 *)

  type state
  val empty   : state
  val drop    : state -> int -> state option   (* NONE if column full *)
  val legalCols : state -> int list            (* non-full columns *)
  val height  : state -> int -> int            (* filled rows in column c *)
  val get     : state -> int -> int -> int     (* get row col: 0=empty,1=R,2=Y *)
  val toMove  : state -> int                   (* 1 = Red, 2 = Yellow *)
  val winner  : state -> int option
  val isDraw  : state -> bool
  val terminal : state -> bool
  val toString : state -> string
  val bestMove : int -> state -> int option    (* bestMove depth state -> col *)
  val Red    : int
  val Yellow : int
end
