# brainfuck
The first ever Brainfuck interpreter written in Eiffel

## What is Brainfuck?

Brainfuck is an esoteric programming language created in 1993 by Urban Müller. It is notable for its extreme minimalism, consisting of only eight commands while being Turing complete. The language operates on an array of memory cells, each initially set to zero, with a pointer that can move to manipulate these cells.

### Commands
- `>` : Move pointer right
- `<` : Move pointer left
- `+` : Increment current cell
- `-` : Decrement current cell
- `.` : Output current cell value as ASCII character
- `,` : Input a character and store in current cell
- `[` : Jump forward to matching `]` if current cell is 0
- `]` : Jump back to matching `[` if current cell is not 0

## Example Program

Here's a simple "Hello, World!" program in Brainfuck:

```brainfuck
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```

## Running the Interpreter

1. First, ensure you have the Serpent Eiffel compiler installed. Follow the installation instructions at [Serpent's GitHub repository](https://github.com/samedit66/serpent).

2. Clone this repository:
   ```bash
   git clone https://github.com/samedit66/brainfuck.git
   cd brainfuck
   ```

3. Compile the project:
   ```bash
   serpent build
   ```

4. Run the interpreter:
   ```bash
   serpent run
   ```

## Usage

The interpreter runs in an interactive REPL (Read-Eval-Print Loop) mode. When you start the interpreter, you'll see a welcome message and a prompt:

```
Welcome to Brainfuck interpreter!
Enter ':quit' to exit.
> 
```

You can type Brainfuck code directly at the prompt and press Enter to execute it. The interpreter will immediately execute your code and show the output. After execution, it will show a new prompt for more input.

For example:
```
> ++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
Hello World!

> 
```

To exit the interpreter, type `:quit` at the prompt.

## License

This project is open source and available under the Apache License 2.0.