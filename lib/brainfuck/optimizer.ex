defmodule Brainfuck.Optimizer do
  def optimize(ast) do
    ast
    |> remove_redundant(:at_start)
    |> do_optimize([])
    |> remove_redundant(:at_end)
  end

  defp do_optimize([], optimized), do: Enum.reverse(optimized)

  defp do_optimize([:zero, {:inc, _n} = inc | rest], optimized),
    do: do_optimize([inc | rest], optimized)

  defp do_optimize([:zero, {:loop, _body} | rest], optimized),
    do: do_optimize([:zero | rest], optimized)

  defp do_optimize([{:inc, _n}, :zero | rest], optimized),
    do: do_optimize([:zero | rest], optimized)

  defp do_optimize([{:inc, n}, {:inc, m} | rest], optimized),
    do: do_optimize([{:inc, n + m} | rest], optimized)

  defp do_optimize([{:inc, 0} | rest], optimized),
    do: do_optimize(rest, optimized)

  defp do_optimize([{:inc, _n}, :in | rest], optimized),
    do: do_optimize([:in | rest], optimized)

  defp do_optimize([{:shift, 0} | rest], optimized),
    do: do_optimize(rest, optimized)

  defp do_optimize([{:shift, n}, {:shift, m} | rest], optimized),
    do: do_optimize([{:shift, n + m} | rest], optimized)

  defp do_optimize([{:loop, body} | rest], optimized),
    do: do_optimize(rest, [{:loop, do_optimize(body, [])} | optimized])

  defp do_optimize([command | rest], optimized),
    do: do_optimize(rest, [command | optimized])

  defp remove_redundant(ast, :at_start),
    do: ast |> Enum.drop_while(&match?({:loop, _body}, &1))

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
