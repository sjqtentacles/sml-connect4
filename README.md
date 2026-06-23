# sml-connect4

[![CI](https://github.com/sjqtentacles/sml-connect4/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-connect4/actions/workflows/ci.yml)

A pure Standard ML **Connect Four** engine: legal-move generation, win/draw detection, and adversarial search via the vendored `sml-gametree` alpha-beta engine.

No FFI, no threads, no clock. Byte-identical under **MLton** and **Poly/ML**.

## Running `make example` prints:

```
=== Connect Four ===
Empty board:
0123456
.......
.......
.......
.......
.......
.......

Vertical win (Red plays col 0 x4, Yellow col 1 x3):
0123456
.......
.......
R......
RY.....
RY.....
RY.....
Winner: Red

Horizontal win (Red plays cols 0-3):
0123456
.......
.......
.......
.....Y.
.....Y.
RRRR.Y.
Winner: Red

=== Win-in-1 detection ===
0123456
.......
.......
.......
.....Y.
.....Y.
RRR..Y.
Best move for Red: col 3 (completes 4 in a row)
```

## API

```sml
val empty      : state
val drop       : state -> int -> state option   (* NONE if column full *)
val legalCols  : state -> int list
val height     : state -> int -> int
val get        : state -> int -> int -> int     (* row col -> 0|Red|Yellow *)
val toMove     : state -> int
val winner     : state -> int option
val isDraw     : state -> bool
val terminal   : state -> bool
val toString   : state -> string
val bestMove   : int -> state -> int option     (* depth -> best column *)
val Red : int   val Yellow : int
val ROWS : int  val COLS : int
```

## Build & test

```sh
make test && make test-poly   # or: make all-tests
make example
```

## Tests

**23 deterministic checks**: empty board, drop, full-column rejection, vertical/horizontal/diagonal wins, terminal detection, win-in-1 bestMove, toString.

## License

MIT. See [LICENSE](LICENSE).
