# Chess Simulation – Bash

This part of the assignment required implementing a simple chess simulator
using Bash, with a small Python helper. The PGN format and basic script
structure were provided; my work was to complete the logic and handle all
movement rules.

## Files

- **chess_sim.sh** – reads PGN metadata, parses moves, updates an 8×8 board,
  and handles captures, promotions, castling, and en passant.
- **parse_moves.py** – given as part of the assignment; normalizes PGN moves
  into simplified UCI-style strings (e.g., `e2e4`, `g7g8q`).

## Usage

To run the simulator, execute the shell script with a path to a PGN file:

```bash
./chess_sim.sh ./PGNfiles/capmemel24_1.pgn

During execution, you can navigate through the game states:

d – next move

a – previous move

w – jump to the first position

s – jump to the final position

q – exit the program
