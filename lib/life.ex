defmodule Life do
  @seed_representation "x"
  @defaults [
    initial: nil,
    board: {14, 80},
    generations: 24,
    period: 200
  ]

  def play(opts \\ []) do
    opts = Keyword.merge(@defaults, opts)

    generations = 1..opts[:generations]
    initial = if is_tuple(opts[:board]) do
      {rows,columns} = opts[:board]
      seed(board(rows, columns), opts[:seed])
    else
      seed_from_representation(opts[:board])
    end
    next = fn _, board ->
      future = tick(board)
      future |> inspect_board |> display_board(opts[:period])
      {future, future}
    end

    {_,_} = Enum.map_reduce(generations, initial, next)
    :ok
  end

  def board(nr, nc) do
    Enum.map 1..nr, fn _ ->
      Enum.map 1..nc, fn _ ->
        false
      end
    end
  end

  def seed_from_representation(representation) do
    rows = representation |> String.split("\n")
    columns = rows |> List.first |> String.graphemes
    seeds =
      rows
      |> Enum.with_index
      |> Enum.flat_map(fn {row, r} ->
        row
        |> String.codepoints
        |> Enum.with_index
        |> Enum.filter(fn {col,_} -> col == @seed_representation end)
        |> Enum.map(fn {_,c} -> {r, c} end)
      end)

    seed(board(length(rows), length(columns)), seeds)
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
      {_,    3} -> true
      {true, 2} -> true
      {true, _} -> false
      _         -> false
    end
  end

  def inspect_cell(cell) when cell == true,  do: "◉"
  def inspect_cell(cell) when cell == false, do: " "

  def inspect_board(board) do
    Enum.map_join board, "\n", fn row ->
      Enum.map_join row, &inspect_cell/1
    end
  end

  def display_board(representation, period) when is_binary(representation) do
    IO.write :os.cmd('clear')
    IO.puts representation
    :timer.sleep(period)
  end
end
