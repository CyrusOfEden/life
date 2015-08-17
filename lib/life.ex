defmodule Life do
  def play({nr, nc}, opts \\ []) do
    opts = Keyword.merge([generations: 24, seed: []], opts)

    range = 1..opts[:generations]
    start = tick(board(nr, nc), opts[:seed])
    next = fn _, board ->
      future = tick(board, next_state(board))
      {future, future}
    end

    {ticks,_} = Enum.map_reduce(range, start, next)

    Enum.each(ticks, &show/1)
  end

  def board(nr, nc) do
    Enum.map 1..nr, fn _ ->
      Enum.map 1..nc, fn _ ->
        false
      end
    end
  end

  def get([row|_] = board, {r, c}) when r < length(board) and
                                        c < length(row) do
    board |> Enum.at(r) |> Enum.at(c)
  end
  def get(_, _), do: nil

  def update(board, {cr, cc, value}) do
    board |> List.update_at cr, fn row ->
      row |> List.replace_at cc, value
    end
  end

  @neighbours [
    {-1, -1}, {-1, 0}, {-1, 1},
    { 0, -1},          { 0, 1},
    { 1, -1}, { 1, 0}, { 1, 1}
  ]
  def get_neighbours(board, {r, c}) do
    Enum.count @neighbours, fn {nr, nc} ->
      get(board, {r + nr, c + nc})
    end
  end

  def tick(board, []), do: board
  def tick(board, [{_,_,_}|_] = coords) do
    Enum.reduce coords, board, &update(&2, &1)
  end

  def next_state(board) do
    board |> Enum.with_index |> Enum.flat_map fn {row, r} ->
      row |> Enum.with_index |> Enum.map fn {cell, c} ->
        {r, c, next_cell_state(board, cell, {r, c})}
      end
    end
  end

  def next_cell_state(board, cell, coord) do
    case {cell, get_neighbours(board, coord)} do
      {true,  n} when n <= 3 -> true
      {true,  n} when n > 3  -> false
      {false, n} when n == 3 -> true
      _                      -> false
    end
  end

  def show(board) do
    Enum.each board, fn row ->
      Enum.each row, fn cell ->
        IO.write show_cell(cell)
      end
      IO.puts ""
    end
    :timer.sleep(100)
  end

  def show_cell(cell) when cell == true, do: "x"
  def show_cell(cell) when cell == false, do: "."
end
