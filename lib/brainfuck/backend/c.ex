defmodule Brainfuck.Backend.C do
  @prologue [
    "#include <string.h>",
    "#include <stdio.h>",
    "int main(void) {",
    "int i = 0;",
    "char arr[30000];",
    "memset(arr, 0, sizeof(arr));"
  ]

  @epilogue [
    "return 0;",
    "}"
  ]

  def generate(ast) do
    (@prologue ++ do_generate(ast) ++ @epilogue)
    |> Enum.join("\n")
  end

  defp do_generate(:out), do: "putchar(arr[i]);"
  defp do_generate(:in), do: "arr[i] = getchar();"
  defp do_generate(:zero), do: "arr[i] = 0;"
  defp do_generate({:inc, n}) when n >= 0, do: "arr[i] += #{n};"
  defp do_generate({:inc, n}), do: "arr[i] -= #{abs(n)};"
  defp do_generate({:shift, n}) when n >= 0, do: "i += #{n};"
  defp do_generate({:shift, n}), do: "i -= #{abs(n)};"

  defp do_generate({:loop, body}),
    do: ["while(arr[i]) {"] ++ Enum.map(body, &do_generate/1) ++ ["}"]

  defp do_generate(ast), do: Enum.map(ast, &do_generate/1) |> List.flatten()
end
