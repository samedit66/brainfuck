defmodule Brainfuck.Optimizer do
  @doc """
  Optimizes given `ast`.
  The following optimization techniques are used:
  - Squeezes sequences like `+++.` into just `.`.
  - Combines sequentional increments and decrements into a single instruction:
    `+++--` becomes `+`.
  - Does the same for shifting: `>>>><<` becomes `>>`.
  - Drops dead loops at the very beggining of the program, when all cells are zero:
    `[+->><.>]++` becomes just `++`.
    Also, it removes loops in the following scenario:
    `>>>[+->>]++` becomes `++`.
  - Removes sequentional loops: `[>][<]` becomes `[>]`.
  - Drops dead code at the end: `+++++.>>><-` becomes `+++++.`.
    This optimization is quite destructive, because in the following code
    the infinity loop at the end will also be removed: `+++.[-+]` becomes `+++.`.
    It is not considered to be a bug, it's a feature!

  ## Examples

      iex> Brainfuck.Optimizer.optimize([{:inc, 10}, {:inc, -4}, :out])
      [{:inc, 6}, :out]

  Note, that if you run `optimize` on the code which has not IO,
  you'll see nothing:

      iex> Brainfuck.Optimizer.optimize([{:inc, 10}, {:inc, -4}])
      []

  It's not a bug: no IO happens, no interactions with user, no computations performed.

  """
  def optimize(ast) do
    ast
    |> peephole_optimize([])
    |> remove_redundant(:at_start)
    |> remove_redundant(:at_end)
  end

  defp peephole_optimize([], optimized),
    do: Enum.reverse(optimized)

  defp peephole_optimize([:zero, :in | rest], optimized),
    do: peephole_optimize([:in | rest], optimized)

  defp peephole_optimize([:zero, {:inc, _n} = inc | rest], optimized),
    do: peephole_optimize([inc | rest], optimized)

  defp peephole_optimize([:zero, {:loop, _body} | rest], optimized),
    do: peephole_optimize([:zero | rest], optimized)

  defp peephole_optimize([{:inc, _n}, :zero | rest], optimized),
    do: peephole_optimize([:zero | rest], optimized)

  defp peephole_optimize([{:inc, n}, {:inc, m} | rest], optimized),
    do: peephole_optimize([{:inc, n + m} | rest], optimized)

  defp peephole_optimize([{:inc, 0} | rest], optimized),
    do: peephole_optimize(rest, optimized)

  defp peephole_optimize([{:inc, _n}, :in | rest], optimized),
    do: peephole_optimize([:in | rest], optimized)

  defp peephole_optimize([{:shift, 0} | rest], optimized),
    do: peephole_optimize(rest, optimized)

  defp peephole_optimize([{:shift, n}, {:shift, m} | rest], optimized),
    do: peephole_optimize([{:shift, n + m} | rest], optimized)

  defp peephole_optimize([{:loop, _b1} = first, {:loop, _b2} | rest], optimized),
    do: peephole_optimize([first | rest], optimized)

  defp peephole_optimize([{:loop, body} | rest], optimized),
    do:
      peephole_optimize(
        rest,
        [{:loop, peephole_optimize(body, [])} | optimized]
      )

  defp peephole_optimize([command | rest], optimized),
    do: peephole_optimize(rest, [command | optimized])

  defp remove_redundant([{:shift, _n}, {:loop, _body} | rest], :at_start),
    do: remove_redundant(rest, :at_start)

  defp remove_redundant(ast, :at_start),
    do: ast |> Enum.drop_while(&match?({:loop, _body}, &1))

  defp remove_redundant(ast, :at_end) do
    ast
    |> Enum.reverse()
    |> Enum.drop_while(fn
      :in -> false
      :out -> false
      {:loop, body} -> not io_inside?(body)
      _ -> true
    end)
    |> Enum.reverse()
  end

  defp io_inside?([]), do: false
  defp io_inside?([:in | _rest]), do: true
  defp io_inside?([:out | _rest]), do: true
  defp io_inside?([{:loop, body} | rest]), do: io_inside?(body) || io_inside?(rest)
  defp io_inside?([_command | rest]), do: io_inside?(rest)
end
