class
    APPLICATION

create
    make
    
feature
                    
    make
        -- Main entry point that reads and executes Brainfuck code until ':quit' is entered
    local
        input_line: STRING
        executor: EXECUTOR
        memory: MEMORY
    do
        print ("Welcome to Brainfuck interpreter!%N")
        print ("Enter ':quit' to exit.%N")

        create memory.make (30 * 100 * 100)
        create executor.make (memory)

        from
            print ("> ")
            io.read_line
            input_line := io.last_string
        until 
            input_line.is_equal (":quit")
        loop
            -- Execute the Brainfuck code from the input line
            executor.execute (input_line)
            
            -- Print newline and prompt for next input
            print ("%N> ")
            io.read_line
            input_line := io.last_string
        end
        
        print ("Goodbye!%N")
    end
end
