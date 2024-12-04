# Advent of Code 2024 Solutions

Welcome to my repository for the [Advent of Code 2024](https://adventofcode.com/) challenges! This collection showcases my solutions to the daily programming puzzles released throughout December 2024.

## Repository Structure

The repository is organized as follows:
```
AOC24/
├── data/       # Contains input data for each day's puzzle
└── src/        # Source code files for each solution
```
## Solutions

Each day's solution is implemented in [Zig](https://ziglang.org/), a robust and efficient programming language. The solutions are located in the `src/` directory, with corresponding input data in the `data/` directory.

## Running the Solutions

1. Ensure [Zig](https://ziglang.org/download/) is installed on your system.

2. Clone this repo
   ```sh
   git clone https://github.com/Alfagov/AOC24.git
   ```
3. Build
   ```sh
   zig build
   ```
4. Run
   ```sh
   ./zig-out/bin/AOC24 <command> [args]
   ```

To execute all solutions:
   ```sh
   ./zig-out/bin/AOC24 all
   ```

To execute single solution:
   ```sh
   ./zig-out/bin/AOC24 day X Y
   ```
Replace X with the day and Y with the part 1/2.

Happy coding!

