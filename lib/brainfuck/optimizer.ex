defmodule Brainfuck.Optimizer do
  def optimize(ast) do
    ast
    |> simplify_arithemtic([])
    |> remove_redundant(:at_start)
    |> remove_redundant(:at_end)
  end

  defp simplify_arithemtic([], optimized), do: Enum.reverse(optimized)

  defp simplify_arithemtic([:zero, :in | rest], optimized),
    do: simplify_arithemtic([:in | rest], optimized)

  defp simplify_arithemtic([:zero, {:inc, _n} = inc | rest], optimized),
    do: simplify_arithemtic([inc | rest], optimized)

  defp simplify_arithemtic([:zero, {:loop, _body} | rest], optimized),
    do: simplify_arithemtic([:zero | rest], optimized)

  defp simplify_arithemtic([{:inc, _n}, :zero | rest], optimized),
    do: simplify_arithemtic([:zero | rest], optimized)

  defp simplify_arithemtic([{:inc, n}, {:inc, m} | rest], optimized),
    do: simplify_arithemtic([{:inc, n + m} | rest], optimized)

  defp simplify_arithemtic([{:inc, 0} | rest], optimized),
    do: simplify_arithemtic(rest, optimized)

  defp simplify_arithemtic([{:inc, _n}, :in | rest], optimized),
    do: simplify_arithemtic([:in | rest], optimized)

  defp simplify_arithemtic([{:shift, 0} | rest], optimized),
    do: simplify_arithemtic(rest, optimized)

  defp simplify_arithemtic([{:shift, n}, {:shift, m} | rest], optimized),
    do: simplify_arithemtic([{:shift, n + m} | rest], optimized)

  defp simplify_arithemtic([{:loop, body} | rest], optimized),
    do: simplify_arithemtic(rest, [{:loop, simplify_arithemtic(body, [])} | optimized])

  defp simplify_arithemtic([command | rest], optimized),
    do: simplify_arithemtic(rest, [command | optimized])

  defp remove_redundant([{:shift, _n}, {:loop, _body} | rest], :at_start),
    do: remove_redundant(rest, :at_start)

  defp remove_redundant(ast, :at_start),
    do: ast |> Enum.drop_while(&match?({:loop, _body}, &1))

  defp remove_redundant([], :at_end), do: []
  defp remove_redundant([:in], :at_end), do: [:in]
  defp remove_redundant([:out], :at_end), do: [:out]

  defp remove_redundant([{:loop, body}] = loop, :at_end) do
    if io_inside?(body), do: [loop], else: []
  end

  defp remove_redundant([_command], :at_end), do: []

  defp remove_redundant([command | rest], :at_end) do
    case remove_redundant(rest, :at_end) do
      [] -> remove_redundant([command], :at_end)
      commands -> [command | commands]
    end
  end

  defp io_inside?([]), do: false
  defp io_inside?([:in | _rest]), do: true
  defp io_inside?([:out | _rest]), do: true
  defp io_inside?([{:loop, body} | rest]), do: io_inside?(body) || io_inside?(rest)
end
