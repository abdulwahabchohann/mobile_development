import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(SpinTheBottleApp());

class SpinTheBottleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spin the Bottle',
      theme: ThemeData(primarySwatch: Colors.blueAccent),
      debugShowCheckedModeBanner: false,
      home: PlayerInputScreen(),
    );
  }
}

class PlayerInputScreen extends StatefulWidget {
  @override
  _PlayerInputScreenState createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  final List<String> playerNames = [];
  final _formKey = GlobalKey<FormState>();
  final _playerControllers = List.generate(10, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _playerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Player Names')),
      body: Container(
        color: Colors.blueAccent[100], // Set the desired background color here
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _playerControllers[index],
                        decoration: InputDecoration(labelText: 'Player ${index + 1}'),
                        validator: (value) {
                          if (index == 0 && (value == null || value.isEmpty)) {
                            return 'At least one player is required';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    playerNames.clear();
                    for (var controller in _playerControllers) {
                      if (controller.text.isNotEmpty) {
                        playerNames.add(controller.text);
                      }
                    }
                    if (playerNames.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottleSelectionScreen(playerNames: playerNames),
                        ),
                      );
                    }
                  }
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottleSelectionScreen extends StatelessWidget {
  final List<String> playerNames;

  BottleSelectionScreen({required this.playerNames});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Bottle')),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(4, (index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BottleFlipScreen(
                    playerNames: playerNames,
                    bottleImage: 'assets/bottle_${index + 1}.png', // Ensure the asset path is correct
                  ),
                ),
              );
            },
            child: Image.asset('assets/bottle_${index + 1}.png', width: 100, height: 100), // Ensure the asset path is correct
          );
        }),
      ),
    );
  }
}

class BottleFlipScreen extends StatefulWidget {
  final List<String> playerNames;
  final String bottleImage;

  BottleFlipScreen({required this.playerNames, required this.bottleImage});

  @override
  _BottleFlipScreenState createState() => _BottleFlipScreenState();
}

class _BottleFlipScreenState extends State<BottleFlipScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  String? flipResult;
  String? challenge;
  bool isBottleStanding = false;

  final double tolerance = 0.1; // Increased tolerance for testing (adjust as needed)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _rotationAnimation = Tween<double>(begin: 0, end: _randomFlipAngle()).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Add listener to handle when the animation ends
    _rotationAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _determineFlipResult(); // Check the rotation when animation ends
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _randomFlipAngle() {
    return Random().nextDouble() * 2 * pi;
  }

  void _flipBottle() {
    setState(() {
      flipResult = null; // Reset the flip result
      challenge = null; // Reset the challenge
    });
    _controller.reset();
    _controller.forward(); // Start the flip animation
  }

  void _determineFlipResult() {
    double finalRotation = _rotationAnimation.value % (2 * pi);

    // Check if it's within a certain range of upright (0 radians) or inverted (π radians)
    bool stands = (finalRotation < tolerance || (finalRotation > pi - tolerance && finalRotation < pi + tolerance));

    setState(() {
      isBottleStanding = stands;

      // If the bottle is standing, show a dare
      if (isBottleStanding) {
        flipResult = 'Bottle Stands!';
        challenge = getRandomChallenge();
      } else {
        flipResult = 'Bottle Falls! Try again.';
        challenge = null; // Ensure challenge is null if the bottle doesn't stand
      }
    });
  }

  String getRandomChallenge() {
    final challenges = [
      'Dance for 1 minute',
      'Sing a song',
      'Do 10 push-ups',
      'Tell a funny joke',
      'Do a cartwheel',
      'Imitate an animal',
      'Share a secret',
    ];
    return challenges[Random().nextInt(challenges.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bottle Flip Challenge')),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          _flipBottle(); // Start bottle flip on swipe
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _rotationAnimation,
                child: Image.asset(widget.bottleImage, width: 200),
              ),
              SizedBox(height: 50),
              if (flipResult != null) Text(flipResult!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (challenge != null) ...[
                SizedBox(height: 20),
                Text('Challenge: $challenge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
              ElevatedButton(
                onPressed: _flipBottle,
                child: Text('Flip Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
