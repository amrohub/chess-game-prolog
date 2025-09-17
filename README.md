### Prolog-based Expert Chess Advisor ♟️

[cite_start]This project is a chess engine that acts as an **expert advisor** for players[cite: 321]. [cite_start]Developed in Prolog, it leverages the language's **declarative nature** to logically evaluate board positions and suggest the best possible moves[cite: 322, 325]. [cite_start]The program is built on **facts** that represent piece positions and **rules** that encode chess strategies[cite: 328].

[cite_start]It uses a **Minimax algorithm** to simulate potential moves and predict an opponent's counter-moves, aiming to minimize losses in a worst-case scenario[cite: 330, 331]. [cite_start]The engine also incorporates **alpha-beta pruning**, an optimization technique that significantly speeds up the search for the best move by eliminating unproductive search paths[cite: 332, 334].

[cite_start]This tool is designed to enhance a player's strategic understanding and improve gameplay by providing logical insights and move suggestions[cite: 326, 335].

---
### Features
* [cite_start]**Logical Evaluation**: Analyzes the board based on factors like piece value, king safety, and board control[cite: 323].
* [cite_start]**Move Suggestions**: Recommends the best move by simulating different scenarios and forecasting their consequences[cite: 324, 335].
* [cite_start]**Efficient Search**: Optimizes the search for the best move using the Minimax algorithm with alpha-beta pruning[cite: 330, 332, 334].
* [cite_start]**Declarative Design**: Focuses on **what** a valid move is, not **how** to execute it, making the code clean and effective[cite: 325].

---
### How to Run
1.  Ensure you have a Prolog environment installed.
2.  Load the project files (`utils.pl`, `pieces.pl`, `evaluator.pl`, `chessboard.pl`) into your Prolog console.
3.  Run the main predicate, which is typically `run.` or `play.`.

[cite_start]This program offers both a human-vs-human mode and a human-vs-AI mode where the AI provides advice[cite: 566].
