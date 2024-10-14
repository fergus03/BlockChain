// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public owner;
    uint256 public constant betAmount = 0.0001 ether;  // tBNB in testnet

    enum Choice { Rock, Paper, Scissors }
    enum GameResult { Player1Win, Player2Win, Draw, NotFinished }

    struct Game {
        address payable player1;
        address payable player2;
        Choice player1Choice;
        Choice player2Choice;
        bool player1MadeChoice;
        bool player2MadeChoice;
        GameResult result; // Store the result of the game
    }

    mapping(uint256 => Game) public games;
    uint256 public gameIdCounter;

    constructor() {
        owner = msg.sender;
        gameIdCounter = 1;
    }

    // Create a new game and register Player 1
    function createGame() public payable {
        require(msg.value == betAmount, "You must bet exactly 0.0001 tBNB.");
        games[gameIdCounter] = Game(payable(msg.sender), payable(address(0)), Choice.Rock, Choice.Rock, false, false, GameResult.NotFinished);
        gameIdCounter++;
    }

    // Join an existing game as Player 2
    function joinGame(uint256 gameId) public payable {
        Game storage game = games[gameId];
        require(game.player2 == address(0), "Game already has two players.");
        require(msg.value == betAmount, "You must bet exactly 0.0001 tBNB.");
        game.player2 = payable(msg.sender);
    }

    // Player 1 makes their choice
    function player1MakeChoice(uint256 gameId, Choice _choice) public {
        Game storage game = games[gameId];
        require(msg.sender == game.player1, "You are not Player 1.");
        game.player1Choice = _choice;
        game.player1MadeChoice = true;
    }

    // Player 2 makes their choice
    function player2MakeChoice(uint256 gameId, Choice _choice) public {
        Game storage game = games[gameId];
        require(msg.sender == game.player2, "You are not Player 2.");
        game.player2Choice = _choice;
        game.player2MadeChoice = true;

        // Once both players have made their choices, resolve the game
        if (game.player1MadeChoice && game.player2MadeChoice) {
            resolveGame(gameId);
        }
    }

    // Resolve the game and distribute the rewards
    function resolveGame(uint256 gameId) internal {
        Game storage game = games[gameId];
        require(game.player1MadeChoice && game.player2MadeChoice, "Both players must make a choice.");

        GameResult result = determineWinner(game.player1Choice, game.player2Choice);
        game.result = result;  // Set the result of the game

        // Debugging: Log the choices and result
        emit GameResolved(game.player1Choice, game.player2Choice, result);

        // Distribute rewards based on the result
        if (result == GameResult.Player1Win) {
            uint256 reward = betAmount * 2;  // Player 1 wins and gets both bets
            game.player1.transfer(reward);
        } else if (result == GameResult.Player2Win) {
            uint256 reward = betAmount * 2;  // Player 2 wins and gets both bets
            game.player2.transfer(reward);
        } else if (result == GameResult.Draw) {
            game.player1.transfer(betAmount);  // Refund Player 1
            game.player2.transfer(betAmount);  // Refund Player 2
        }
    }

    // Determine the winner based on choices
    function determineWinner(Choice player1Choice, Choice player2Choice) internal pure returns (GameResult) {
        if (player1Choice == player2Choice) {
            return GameResult.Draw;
        }

        if (
            (player1Choice == Choice.Rock && player2Choice == Choice.Scissors) ||
            (player1Choice == Choice.Paper && player2Choice == Choice.Rock) ||
            (player1Choice == Choice.Scissors && player2Choice == Choice.Paper)
        ) {
            return GameResult.Player1Win;
        }

        return GameResult.Player2Win;
    }

    // Function to get the game result
    function getGameResult(uint256 gameId) public view returns (GameResult) {
        return games[gameId].result;
    }

    // Fallback function to accept payments to the contract
    receive() external payable {}

    // Debugging event to log game resolution
    event GameResolved(Choice player1Choice, Choice player2Choice, GameResult result);
}
