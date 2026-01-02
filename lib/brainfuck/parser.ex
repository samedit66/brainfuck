defmodule Brainfuck.Parser do
  @tokens [
    ">",
    "<",
    "+",
    "-",
    ".",
    ",",
    "[",
    "]"
  ]

  @doc ~S"""
  Parses given brainfuck `code` into intermediate representation.
  Cleans up `code`, removing any non-brainfuck tokens.

  ## Examples

      iex> Brainfuck.Parser.parse("+")
      {:ok, [inc: 1]}

      iex> Brainfuck.Parser.parse("-")
      {:ok, [inc: -1]}

      iex> Brainfuck.Parser.parse(">")
      {:ok, [shift: 1]}

      iex> Brainfuck.Parser.parse("<")
      {:ok, [shift: -1]}

      iex> Brainfuck.Parser.parse(".")
      {:ok, [:out]}

      iex> Brainfuck.Parser.parse(",")
      {:ok, [:in]}

      iex> Brainfuck.Parser.parse("[]")
      {:ok, [loop: []]}

      iex> Brainfuck.Parser.parse("[-]")
      {:ok, [:zero]}

      iex> Brainfuck.Parser.parse("[+]")
      {:ok, [:zero]}

      iex> Brainfuck.Parser.parse("This will be deleted")
      {:ok, []}

      iex> Brainfuck.Parser.parse("here we go: +++[->+<]")
      {:ok, [{:inc, 3}, {:loop, [{:inc, -1}, {:shift, 1}, {:inc, 1}, {:shift, -1}]}]}

  Invalid brainfuck code results in an error:

      iex> Brainfuck.Parser.parse("[")
      {:error, "At least one loop is not closed properly."}

      iex> Brainfuck.Parser.parse("]")
      {:error, "Missing loop start."}

  """
  def parse(code) do
    cleaned = code |> String.graphemes() |> clean()

    case do_parse(cleaned, []) do
      {:error, reason} -> {:error, reason}
      ast -> {:ok, ast}
    end
  end

  defp clean(chars),
    do: chars |> Enum.filter(&Enum.member?(@tokens, &1))

  defp do_parse([], commands), do: Enum.reverse(commands)

  defp do_parse(["." | rest], commands),
    do: do_parse(rest, [:out | commands])

  defp do_parse(["," | rest], commands),
    do: do_parse(rest, [:in | commands])

  defp do_parse(["[", "-", "]" | rest], commands),
    do: do_parse(rest, [:zero | commands])

  defp do_parse(["[", "+", "]" | rest], commands),
    do: do_parse(rest, [:zero | commands])

  defp do_parse(["[" | rest], commands) do
    with {:ok, loop_tokens, rest} <- extract_loop(rest, [], 1) do
      do_parse(rest, [{:loop, do_parse(loop_tokens, [])} | commands])
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_parse(["]" | _rest], _commands), do: {:error, "Missing loop start."}

  defp do_parse(["+" | _rest] = tokens, commands) do
    {count, rest} = count(tokens, "+")
    do_parse(rest, [{:inc, count} | commands])
  end

  defp do_parse(["-" | _rest] = tokens, commands) do
    {count, rest} = count(tokens, "-")
    do_parse(rest, [{:inc, -count} | commands])
  end

  defp do_parse([">" | _rest] = tokens, commands) do
    {count, rest} = count(tokens, ">")
    do_parse(rest, [{:shift, count} | commands])
  end

  defp do_parse(["<" | _rest] = tokens, commands) do
    {count, rest} = count(tokens, "<")
    do_parse(rest, [{:shift, -count} | commands])
  end

  defp count(tokens, token) do
    {repeated, rest} = tokens |> Enum.split_while(&(&1 == token))
    {Enum.count(repeated), rest}
  end

  defp extract_loop(["[" | rest], loop_tokens, bracket_level),
    do: extract_loop(rest, ["[" | loop_tokens], bracket_level + 1)

  defp extract_loop(["]" | rest], loop_tokens, 1),
    do: {:ok, Enum.reverse(loop_tokens), rest}

  defp extract_loop(["]" | rest], loop_tokens, bracket_level),
    do: extract_loop(rest, ["]" | loop_tokens], bracket_level - 1)

  defp extract_loop([token | rest], loop_tokens, bracket_level),
    do: extract_loop(rest, [token | loop_tokens], bracket_level)

  defp extract_loop([], _loop_tokens, bracket_level) when bracket_level >= 1,
    do: {:error, "At least one loop is not closed properly."}
end
