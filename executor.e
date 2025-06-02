class
    EXECUTOR

create
    make

feature

    make (a_memory: MEMORY)
    -- Creates a new executor with the given memory
    -- @param a_memory The memory of the executor
    do
        memory := a_memory
    end

feature {NONE}

    memory: MEMORY
    -- Memory of the executor

    code: STRING
    -- Code to execute

    current_index: INTEGER
    -- Current index of the executable code

    running: BOOLEAN
    -- Whether the executor is running

feature

    execute (a_code: STRING)
    -- Executes the given code
    -- @param a_code The code to execute
    do
        code := a_code
        running := True

        from
            current_index := 1
        until
            current_index > code.count or else not running
        loop
            execute_command (code[current_index])
        end

        if current_index > code.count then
            running := False
        end
    end

feature {NONE}

    execute_command (command: CHARACTER): INTEGER
    -- Executes the given command
    -- @param command The command to execute
    -- @return The index of the next command to execute
    local
        right_bracket_index: INTEGER
        left_bracket_index: INTEGER
        jumped: BOOLEAN
    do
        if command = '>' then
            memory.next_cell
        elseif command = '<' then
            memory.previous_cell
        elseif command = '+' then
            memory.increment
        elseif command = '-' then
            memory.decrement
        elseif command = '.' then
            io.put_character (memory.cell.to_character)
        elseif command = ',' then
            io.read_character
            memory.set_cell_value (io.last_character.code_point)
        elseif command = '[' and then memory.cell = 0 then

            if memory.cell = 0 then
                right_bracket_index := find_right_bracket (current_index + 1)
                -- io.put_string ("Right bracket index: " + right_bracket_index.out + "%N")

                if right_bracket_index = 0 then
                    io.put_string ("No matching right bracket found for [ at index " + current_index.out + "%N")
                    io.put_string ("Stopped execution%N")
                    running := False
                else
                    jumped := True
                    current_index := right_bracket_index + 1
                end
            else
                current_index := current_index + 1
            end

        elseif command = ']' then
            left_bracket_index := find_left_bracket (current_index - 1)
            -- io.put_string ("Left bracket index: " + left_bracket_index.out + "%N")

            if left_bracket_index = 0 then
                io.put_string ("No matching left bracket found for ] at index " + current_index.out + "%N")
                io.put_string ("Stopped execution%N")
                running := False
            else
                jumped := True
                current_index := left_bracket_index 
            end
        end

        if not jumped then
            current_index := current_index + 1
        end
    end

feature {NONE}

    find_right_bracket (index_after_left_bracket: INTEGER): INTEGER
    -- Finds the matching bracket (']') starting from the given index
    -- @param index_after_left_bracket The index after the left bracket
    -- @return The index of the matching bracket
    local
        i: INTEGER
        bracket_level: INTEGER
    do
        Result := 0

        from
            i := index_after_left_bracket
            bracket_level := 0
        until
            i > code.count or else (code[i] = ']' and then bracket_level = 0)
        loop
            if code[i] = '[' then
                bracket_level := bracket_level + 1
            elseif code[i] = ']' then
                bracket_level := bracket_level - 1
            end
            i := i + 1
        end

        if i <= code.count then
            Result := i
        end
    end

    find_left_bracket (index_before_right_bracket: INTEGER): INTEGER
    -- Finds the matching bracket ('[') starting from the given index
    -- @param index_before_right_bracket The index before the right bracket
    -- @return The index of the matching bracket
    local
        i: INTEGER
        bracket_level: INTEGER
    do
        Result := 0

        from
            i := index_before_right_bracket
            bracket_level := 0
        until
            i < 1 or else (code[i] = '[' and then bracket_level = 0)
        loop
            if code[i] = ']' then
                bracket_level := bracket_level + 1
            elseif code[i] = '[' then
                bracket_level := bracket_level - 1
            end
            i := i - 1
        end

        if i >= 1 then
            Result := i
        end
    end

end