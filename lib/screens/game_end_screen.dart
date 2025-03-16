import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

class GameEndScreen extends StatefulWidget {
  final List<String> players;
  final VoidCallback onPlayAgain;
  final VoidCallback onNewGame;
  final VoidCallback onHome;

  const GameEndScreen({
    super.key,
    required this.players,
    required this.onPlayAgain,
    required this.onNewGame,
    required this.onHome,
  });

  @override
  State<GameEndScreen> createState() => _GameEndScreenState();
}

class _GameEndScreenState extends State<GameEndScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  final List<Map<String, dynamic>> _endScreens = [
    {
      'id': 'lightweight',
      'title': 'The Lightweight Award',
      'subtitle': 'Maybe stick to juice next time!',
      'icon': '🍺',
      'color': Colors.orange,
      'animation': 'wobble',
    },
    {
      'id': 'hangover',
      'title': 'Hangover Forecast',
      'subtitle': 'Tomorrow\'s Weather: Severe Headache',
      'icon': '⛈️',
      'color': Colors.blue,
      'animation': 'rain',
    },
    {
      'id': 'memory_wipe',
      'title': 'Memory Wipe',
      'subtitle': 'Memories from tonight will self-destruct in 3...2...1...',
      'icon': '🕶️',
      'color': Colors.black,
      'animation': 'flash',
    },
    {
      'id': 'friendship',
      'title': 'Friendship Meter',
      'subtitle': 'Status: Tested but Still Standing',
      'icon': '❤️',
      'color': Colors.red,
      'animation': 'pulse',
    },
    {
      'id': 'legendary',
      'title': 'Legendary Night',
      'subtitle': 'This Night Has Entered the Hall of Fame',
      'icon': '🌟',
      'color': Colors.amber,
      'animation': 'sparkle',
    },
    {
      'id': 'sobriety',
      'title': 'Sobriety Check',
      'subtitle': 'Touch your nose while standing on one foot',
      'icon': '👮',
      'color': Colors.blue,
      'animation': 'shake',
    },
    {
      'id': 'social_ban',
      'title': 'Social Media Ban',
      'subtitle': 'No posting until you\'re sober. We\'re serious.',
      'icon': '📱',
      'color': Colors.purple,
      'animation': 'lock',
    },
    {
      'id': 'group_photo',
      'title': 'Group Photo Moment',
      'subtitle': 'Quick! Take a Photo Before Anyone Leaves!',
      'icon': '📸',
      'color': Colors.pink,
      'animation': 'camera',
    },
    {
      'id': 'hydration',
      'title': 'Hydration Station',
      'subtitle': 'Drink a glass of water for each round you played',
      'icon': '💧',
      'color': Colors.blue,
      'animation': 'water',
    },
    {
      'id': 'classified',
      'title': 'Friend Group Exposed',
      'subtitle': 'What happens in DrunkHub stays in DrunkHub',
      'icon': '🔒',
      'color': Colors.grey,
      'animation': 'redact',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildEndScreen(Map<String, dynamic> screen) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                screen['color'].withOpacity(0.8),
                screen['color'].withOpacity(0.4),
              ],
            ),
          ),
        ),
        
        // Confetti
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: -pi / 2,
          maxBlastForce: 5,
          minBlastForce: 1,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.1,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          strokeWidth: 2,
        ),

        // Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    screen['icon'],
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Text(
                    screen['title'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Text(
                    screen['subtitle'],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: screen['color'],
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: widget.onPlayAgain,
                        child: const Text(
                          'Play Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: widget.onNewGame,
                        child: const Text(
                          'New Game',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onHome,
                        child: const Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Randomly select an end screen
    final randomScreen = _endScreens[Random().nextInt(_endScreens.length)];
    
    return Scaffold(
      body: _buildEndScreen(randomScreen),
    );
  }
} 