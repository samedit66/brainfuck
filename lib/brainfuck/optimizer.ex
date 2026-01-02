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
    |> simplify_arithmetic([])
    |> remove_redundant(:at_start)
    |> remove_redundant(:at_end)
  end

  defp simplify_arithmetic([], optimized), do: Enum.reverse(optimized)

  defp simplify_arithmetic([:zero, :in | rest], optimized),
    do: simplify_arithmetic([:in | rest], optimized)

  defp simplify_arithmetic([:zero, {:inc, _n} = inc | rest], optimized),
    do: simplify_arithmetic([inc | rest], optimized)

  defp simplify_arithmetic([:zero, {:loop, _body} | rest], optimized),
    do: simplify_arithmetic([:zero | rest], optimized)

  defp simplify_arithmetic([{:inc, _n}, :zero | rest], optimized),
    do: simplify_arithmetic([:zero | rest], optimized)

  defp simplify_arithmetic([{:inc, n}, {:inc, m} | rest], optimized),
    do: simplify_arithmetic([{:inc, n + m} | rest], optimized)

  defp simplify_arithmetic([{:inc, 0} | rest], optimized),
    do: simplify_arithmetic(rest, optimized)

  defp simplify_arithmetic([{:inc, _n}, :in | rest], optimized),
    do: simplify_arithmetic([:in | rest], optimized)

  defp simplify_arithmetic([{:shift, 0} | rest], optimized),
    do: simplify_arithmetic(rest, optimized)

  defp simplify_arithmetic([{:shift, n}, {:shift, m} | rest], optimized),
    do: simplify_arithmetic([{:shift, n + m} | rest], optimized)

  defp simplify_arithmetic([{:loop, body} | rest], optimized),
    do: simplify_arithmetic(rest, [{:loop, simplify_arithmetic(body, [])} | optimized])

  defp simplify_arithmetic([command | rest], optimized),
    do: simplify_arithmetic(rest, [command | optimized])

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
