defmodule Brainfuck.Optimizer do
  def optimize(ast) do
    do_optimize(ast, [])
    |> Enum.reverse()
    |> drop_redundant_code()
    |> Enum.reverse()
  end

  defp do_optimize(ast, [{:loop, _body}]), do: do_optimize(ast, [])

  defp do_optimize([], optimized), do: Enum.reverse(optimized)

  defp do_optimize([:zero, {:inc, _n} = inc | rest], optimized),
    do: do_optimize([inc | rest], optimized)

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

  defp do_optimize([{:loop, loop_body} | rest], optimized),
    do: do_optimize(rest, [{:loop, do_optimize(loop_body, [])} | optimized])

  defp do_optimize([command | rest], optimized),
    do: do_optimize(rest, [command | optimized])

  defp drop_redundant_code([:in | _rest] = ast), do: ast
  defp drop_redundant_code([:out | _rest] = ast), do: ast

  defp drop_redundant_code([{:loop, body} | rest] = ast) do
    if io_inside?(body) do
      ast
    else
      drop_redundant_code(rest)
    end
  end

  defp drop_redundant_code([_command | rest]), do: drop_redundant_code(rest)

  defp io_inside?([:in | _rest]), do: true
  defp io_inside?([:out | _rest]), do: true
  defp io_inside?([{:loop, body}]), do: io_inside?(body)
  defp io_inside?(_ast), do: false
end
