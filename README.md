# Codebreaker Rack App

Codebreaker is a logic game in which a code-breaker tries to break a secret code created by a code-maker.
The game uses [codebreaker_artem](https://rubygems.org/gems/codebreaker_artem) gem.

## Usage

[Open app](https://codebreaker-rackapp.herokuapp.com)

### Rules:

The code-maker, which will be played by the application, creates a secret code of four numbers between 1 and 6.

The code-breaker then gets some number of chances to break the code. In each turn, the code-breaker makes a guess of four numbers. The code-maker then marks the guess with up to four + and - signs.

A + indicates an exact match: one of the numbers in the guess is the same as one of the numbers in the secret code and in the same position.

A - indicates a number match: one of the numbers in the guess is the same as one of the numbers in the secret code but in a different position.

1. Start game - When a new game was started, the game generates secret code. The code should have 4 items.

2. Code-breaker submits guess - The code-breaker propose a guess, and the system replies by marking the guess according to the marking algorithm.

3. Code-breaker wins game - The code-breaker propose a guess that matches the secret code exactly. The system responds by marking the guess with four + signs.

4. Code-breaker loses game - After some number of turns, the game tells the code-breaker that the game is over (need to decide how many turns and whether to reveal the code).

5. Code-breaker plays again - After the game is won or lost, the system prompts the code-breaker to play again. If the code-breaker indicates yes, a new game begins. If the code-breaker indicates no, the system shuts down.

6. Code-breaker requests hint - At any time during a game, the code-breaker can request a hint, at which point the system reveals one of the numbers in the secret code.

7. Code-breaker saves score - After the game is won or lost, the code-breaker can opt to save information about the game: who (initials?), score, and time.
