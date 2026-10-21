package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Side :: enum {
	None,
	X,
	O
}

Grid :: [9]Side
Reader :: bufio.Reader

output_grid :: proc(grid: Grid) {
	i: i8 = 1
	for side in grid {
		fmt.print("|")

		switch side {
			case Side.None:
				fmt.print("~")
			case Side.X:
				fmt.print("X")
			case Side.O:
				fmt.print("O")
		}

		if i % 3 == 0 {
			fmt.print("|")
			fmt.print("\n")
		}

		i += 1
	}
}

print_side :: proc(side: Side) {
	switch side {
		case Side.X:
			fmt.print("X: ")
		case Side.O:
			fmt.print("O: ")
		case Side.None:
			fmt.print("None: ")
	}
}

accept_input :: proc(reader: ^Reader) -> Maybe(string) {
	line, err := bufio.reader_read_string(reader, '\n')

    if err != nil {
		if err == .EOF {
			os.exit(0)
		}
    	
        fmt.println("Error reading input:", err)
        return nil
    }

	return line
}

process_command :: proc(grid: ^Grid, turnOfSide: Side, command: string) -> bool {
	fieldNum, ok := strconv.parse_int(strings.trim_space(command))
	delete(command)
	
    if !ok {
        fmt.println("Please enter an integer.")
        return false
    }

    if fieldNum < 1 || fieldNum > 9 {
    	fmt.println("Please enter an integer which is in the range 1-9.")
    	return false
    }

	if grid[fieldNum - 1] != Side.None {
		fmt.println("This field is already taken!")
		return false
	}

    grid[fieldNum - 1] = turnOfSide

    return true
}

check_win_for_side :: proc(grid: ^Grid, side: Side) -> bool {
	if
		(grid[0] == side && grid[1] == side && grid[2] == side) ||
		(grid[3] == side && grid[4] == side && grid[5] == side) ||
		(grid[6] == side && grid[7] == side && grid[8] == side) ||
		(grid[0] == side && grid[4] == side && grid[8] == side) ||
		(grid[2] == side && grid[4] == side && grid[6] == side)
	{
		return true		
	}

	return false
}

check_game_win_condition :: proc(grid: ^Grid) -> Side {
	xWon: bool = check_win_for_side(grid, Side.X)
	if xWon {
		return Side.X
	}

	oWon: bool = check_win_for_side(grid, Side.O)
	if oWon {
		return Side.O
	}
	
	return Side.None
}

check_all_slots_filled :: proc(grid: ^Grid) -> bool {
	emptySlots := 9
	for side in grid {
		if side != Side.None {
			emptySlots -= 1
		}
	}
	return emptySlots <= 0
}

main :: proc() {
	grid: Grid = [9]Side{
		Side.None, Side.None, Side.None,
		Side.None, Side.None, Side.None,
		Side.None, Side.None, Side.None
	}

	reader: bufio.Reader
 	bufio.reader_init(&reader, os.to_stream(os.stdin))
 	defer bufio.reader_destroy(&reader)

 	turnOfSide := Side.X

	for {
			output_grid(grid)

			success := false
			for success == false {
				print_side(turnOfSide)
				line: Maybe(string) = accept_input(&reader)
				if line == nil {
					continue
				}

				success = process_command(&grid, turnOfSide, line.?)
			}

			winningSide: Side = check_game_win_condition(&grid)

			doesWinnerExist := true
			switch winningSide {
				case Side.X:
					fmt.println("X won the game!")
				case Side.O:
					fmt.println("O won the game!")
				case Side.None:
					doesWinnerExist = false
			}

			allSlotsFilled: bool = check_all_slots_filled(&grid)
			if allSlotsFilled && !doesWinnerExist {
				fmt.println("It's a tie!")
			}

			if doesWinnerExist || allSlotsFilled {
				fmt.print("Play again? Y/n\n")

				line: Maybe(string) = accept_input(&reader)
				if line == nil {
					continue
				}

				breakOut := false
				switch strings.to_upper(line.?[0:1]) {
					case "N":
						breakOut = true
					case:
						turnOfSide = Side.X
						grid = [9]Side{
							Side.None, Side.None, Side.None,
							Side.None, Side.None, Side.None,
							Side.None, Side.None, Side.None
						}
				}

				if breakOut {
					break
				}
				
				continue
			}

			switch turnOfSide {
				case Side.X:
					turnOfSide = Side.O
				case Side.O:
					turnOfSide = Side.X
				case Side.None:
					turnOfSide = Side.X
			}
	}
}
