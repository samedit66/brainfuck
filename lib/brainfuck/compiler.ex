defmodule Brainfuck.Compiler do
  alias Brainfuck.Parser
  alias Brainfuck.Optimizer
  alias Brainfuck.Backend

  def compile_file!(bf_file, options \\ []) do
    {:ok, c_code} = File.read!(bf_file) |> compile()

    file_name = Path.basename(bf_file, ".bf")

    c_file = "#{file_name}.c"
    File.write!(c_file, c_code)

    executable = Keyword.get(options, :executable, file_name)
    c_compiler = Keyword.get(options, :c_compiler, "gcc")
    System.cmd(c_compiler, ["-O2", "-o", executable, c_file], into: IO.stream())
  end

  def compile(code) do
    with {:ok, ast} <- Parser.parse(code) do
      code =
        ast
        |> Optimizer.optimize()
        |> Backend.C.generate()

      {:ok, code}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
