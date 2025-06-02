class
    MEMORY

create
    make

feature

    make (size: INTEGER)
    -- Creates a new memory with the given size
    -- @param size The size of the memory
    do
        current_index := 1
        create cells.make_filled (0, 1, size)
    end

feature {NONE}

    current_index: INTEGER
    -- Index of the current memory cell

    cells: ARRAY [INTEGER]
    -- Array of memory cells

feature

    cell: INTEGER
    -- Value of the current memory cell
    then
        cells[current_index]
    end

feature

    set_cell_value (value: INTEGER)
    -- Sets the value of the current memory cell
    do
        cells[current_index] := value
    end

feature

    next_cell
    -- Moves to the next memory cell
    do
        current_index := current_index + 1
    end

    previous_cell
    -- Moves to the previous memory cell
    do
        current_index := current_index - 1
    end

feature

    increment
    -- Increases the value of the current memory cell by 1
    do 
        cells[current_index] := cells[current_index] + 1
    end

    decrement
    -- Decreases the value of the current memory cell by 1
    do
        cells[current_index] := cells[current_index] - 1
    end

end
