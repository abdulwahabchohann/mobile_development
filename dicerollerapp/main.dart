import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Dice Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DiceGame(),
    );
  }
}

class DiceGame extends StatefulWidget {
  @override
  _DiceGameState createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  final int totalRounds = 10;
  int roundsPlayed = 0;
  int currentPlayerTurn = 0;
  List<int> scores = [0, 0, 0, 0];
  List<int> diceValues = [1, 1, 1, 1];
  List<bool> isRolling = [false, false, false, false];

  Timer? _timer;
  int _rollCount = 0;
  final int _maxRollCount = 15;

  void rollDice(int playerIndex) {
    if (isRolling[playerIndex] || currentPlayerTurn != playerIndex) return;

    setState(() {
      isRolling[playerIndex] = true;
      _rollCount = 0;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        diceValues[playerIndex] = Random().nextInt(6) + 1; // Random roll from 1 to 6
      });
      _rollCount++;

      if (_rollCount >= _maxRollCount) {
        _timer?.cancel();
        finishRoll(playerIndex);
      }
    });
  }

  void finishRoll(int playerIndex) {
    setState(() {
      scores[playerIndex] += diceValues[playerIndex];
      isRolling[playerIndex] = false;
      currentPlayerTurn = (currentPlayerTurn + 1) % 4;

      if (currentPlayerTurn == 0) {
        roundsPlayed++;
      }

      if (roundsPlayed >= totalRounds) {
        _showWinnerDialog();
      }
    });
  }

  void _showWinnerDialog() {
    int winnerIndex = scores.indexOf(scores.reduce(max)) + 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Player $winnerIndex wins with ${scores[winnerIndex - 1]} points!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      roundsPlayed = 0;
      scores = [0, 0, 0, 0];
      diceValues = [1, 1, 1, 1];
      currentPlayerTurn = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('4-Player Ludo Dice Game'),
      ),
      body: Container(
        // Apply gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black], // Replace with your desired colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildPlayerUI(0, 'Player 1', Alignment.topLeft),
            _buildPlayerUI(1, 'Player 2', Alignment.topRight),
            _buildPlayerUI(2, 'Player 3', Alignment.bottomLeft),
            _buildPlayerUI(3, 'Player 4', Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  // Helper method to avoid repetitive code for each player
  Widget _buildPlayerUI(int playerIndex, String playerName, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playerName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Image.asset(
              'assets/dice_${diceValues[playerIndex]}.png',
              width: 80,  // Adjusted size for better display
              height: 80,
            ),
            Text('Score: ${scores[playerIndex]}'),
            ElevatedButton(
              onPressed: (isRolling[playerIndex] || currentPlayerTurn != playerIndex) ? null : () => rollDice(playerIndex),
              child: Text('Roll Dice'),
            ),
          ],
        ),
      ),
    );
  }
}
