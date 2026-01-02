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

  defp remove_redundant(ast, :at_start) do
    ast
    |> Enum.split_while(fn
      {:loop, _body} -> true
      _ -> false
    end)
    |> elem(1)
  end

  defp remove_redundant(ast, :at_end) do
    ast
    |> Enum.reverse()
    |> Enum.split_while(fn
      :in -> false
      :out -> false
      {:loop, _body} -> false
      _ -> true
    end)
    |> elem(1)
    |> Enum.reverse()
  end
end
