Life
====

Conway's Game of Life implemented in Elixir.

Quickstart
----------

```elixir
seed = File.read!("seeds/rpentomino.txt")
Life.play(board: seed, generations: 64, period: 250)
# Board is the initial board, can also be a tuple for {rows,columns}
# If so, then pass in `:seed` as a list of 2-tuples of {row,column}
# for initial live cells
#
# `:generations` is the number of generations :)
# `:period` is the number of miiliseconds per generation
```
