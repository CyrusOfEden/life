defmodule Life do
  @period 200 # milliseconds per tick
  @defaults [
    board: {14, 80},
    generations: 24,
    seed: [
      {2, 3}, {2, 4}, {2, 5}, {3, 4},
      {11, 24}, {12, 25}, {12, 26}, {13, 26}
    ]
  ]

  def play(opts \\ []) do
    opts = Keyword.merge(@defaults, opts)

    generations = 1..opts[:generations]
    {rows, columns} = opts[:board]
    initial = seed(board(rows, columns), opts[:seed])
    next = fn _, board ->
      future = tick(board)
      future |> inspect_board |> display_board
      {future, future}
    end

    Enum.map_reduce(generations, initial, next)
    :ok
  end

  def board(nr, nc) do
    Enum.map 1..nr, fn _ ->
      Enum.map 1..nc, fn _ ->
        false
      end
    end
  end

  def seed(board, [{_,_,}|_] = seeds) do
    seeds
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {r, coords} ->
      {r, Enum.map(coords, &elem(&1, 1))}
    end)
    |> Enum.reduce(board, fn {r, cs}, board ->
      List.update_at board, r, fn row ->
        Enum.reduce cs, row, fn c, row ->
          List.replace_at row, c, true
        end
      end
    end)
  end

  def get([row|_] = board, {r, c}) do
    case {r < length(board), c < length(row)} do
      {true, true} -> board |> Enum.at(r) |> Enum.at(c)
      _            -> nil
    end
  end

  @neighbour_coords [
    {-1, -1}, {-1, 0}, {-1, 1},
    { 0, -1},          { 0, 1},
    { 1, -1}, { 1, 0}, { 1, 1}
  ]
  def get_neighbours(board, {r, c}) do
    Enum.count @neighbour_coords, fn {nr, nc} ->
      get(board, {r + nr, c + nc})
    end
  end

  def tick(board) do
    board |> Enum.with_index |> Enum.map fn {row, r} ->
      row |> Enum.with_index |> Enum.map fn {cell, c} ->
        next_cell_state(board, cell, {r, c})
      end
    end
  end

  def next_cell_state(board, cell, coord) do
    case {cell, get_neighbours(board, coord)} do
      {true, n} when n < 3  -> true
      {true, n} when n > 3  -> false
      {_,    n} when n == 3 -> true
      _                     -> false
    end
  end

  def inspect_cell(cell) when cell == true,  do: "◉"
  def inspect_cell(cell) when cell == false, do: " "

  def inspect_board(board) do
    Enum.map_join board, "\n", fn row ->
      Enum.map_join row, &inspect_cell/1
    end
  end

  def display_board(representation) when is_binary(representation) do
    IO.write :os.cmd('clear')
    IO.puts representation
    :timer.sleep(@period)
  end
end
