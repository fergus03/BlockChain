- Create a new game:
Player 1 calls the createGame() function and sends exactly 0.0001 tBNB as the bet.
The contract creates a new game in the games mapping with a unique gameId.
Player 1 is automatically registered as the first player in the game.

- Player 2 joins the game:
Player 2 calls the joinGame(gameId) function, providing the gameId and sending 0.0001 tBNB as the bet.
The contract assigns Player 2 as the second player and updates the game to reflect both players are present.

- Player 1 makes their choice:

Player 1 calls player1MakeChoice(gameId, Choice) and submits their choice (Rock, Paper, or Scissors).
The contract stores Player 1's choice and sets player1MadeChoice = true.

- Player 2 makes their choice:

Player 2 calls player2MakeChoice(gameId, Choice) and submits their choice.
The contract stores Player 2's choice and sets player2MadeChoice = true.
When both players have made their choices, the contract proceeds to resolve the game.

- Resolve the game:

The resolveGame(gameId) function checks if both players have made their choices.
The contract calls determineWinner() to compare the players' choices and returns the result:
GameResult.Player1Win — Player 1 wins.
GameResult.Player2Win — Player 2 wins.
GameResult.Draw — It's a tie.

- Distribute rewards:

If Player 1 wins, they receive the total bet amount (0.0002 tBNB).
If Player 2 wins, they receive the total bet amount (0.0002 tBNB).
In case of a draw, both players get their original bet (0.0001 tBNB) back.

- Check the result:

Use the getGameResult(gameId) function to check the final result.