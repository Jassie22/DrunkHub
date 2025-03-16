import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_prompt.dart';
import '../models/game_package.dart';

class GameScreen extends StatefulWidget {
  final List<String> players;
  final List<GamePackage> selectedPackages;

  const GameScreen({
    super.key,
    required this.players,
    required this.selectedPackages,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<GamePrompt> _prompts;
  late List<String> _shuffledPlayers;
  int _currentPromptIndex = -1;
  bool _showTutorial = true;
  static const int maxPrompts = 25;
  String? _currentTargetPlayer;
  
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  late Animation<double> _rotationAnimation;
  bool _isAnimating = false;
  double _dragPosition = 0;
  double _dragTotal = 0;  // Track total drag distance
  Offset _dragStartPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _setupAnimations();
  }

  void _initializeGame() {
    // Generate and shuffle prompts
    _prompts = GamePrompt.generatePromptsFromPackages(widget.selectedPackages);
    _prompts.shuffle();
    
    // Limit to maxPrompts if needed
    if (_prompts.length > maxPrompts) {
      _prompts = _prompts.sublist(0, maxPrompts);
    }
    
    // Shuffle players
    _shuffledPlayers = List.from(widget.players);
    _shuffledPlayers.shuffle();
  }

  void _showGameEndDialog() {
    final List<String> funMessages = [
      "🎉 Game Over! You've survived another epic drinking session!",
      "🌟 Congratulations! You've made it to the end without spilling (hopefully)!",
      "🎊 That's all folks! Time to drink some water!",
      "🎯 Mission accomplished! Remember to drink responsibly!",
      "🌈 Game complete! Hope you had as much fun playing as we had creating this!",
    ];
    
    final randomMessage = funMessages[Random().nextInt(funMessages.length)];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎮 Game Complete! 🎮',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                randomMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Text(
                "Don't forget to drink water! 💧",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Start'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      _currentPromptIndex = -1;
      _showTutorial = true;
    });
  }

  void _setupAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));

    // Tutorial animation
    if (_showTutorial) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _startTutorialAnimation();
      });
    }
  }

  void _startTutorialAnimation() {
    if (!mounted) return;
    
    setState(() {
      _isAnimating = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _cardController.forward().then((_) {
        _cardController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            _isAnimating = false;
          });
        });
      });
    });
  }

  String _getRandomPlayer({String? exclude}) {
    List<String> availablePlayers = exclude != null ? 
      _shuffledPlayers.where((p) => p != exclude).toList() : 
      _shuffledPlayers;
    return availablePlayers[Random().nextInt(availablePlayers.length)];
  }

  void _nextPrompt() {
    if (_isAnimating) return;

    print("Moving to next prompt - CLICK HANDLER CALLED"); // Enhanced debug print
    
    setState(() {
      if (_showTutorial) {
        _showTutorial = false;
        _currentPromptIndex = 0;
      } else {
        if (_currentPromptIndex >= _prompts.length - 1) {
          _showGameEndDialog();
          return;
        }
        _currentPromptIndex++;
      }
      // Update the current target player when moving to next prompt
      _currentTargetPlayer = _getRandomPlayer();
    });
    
    // Reset drag state after advancing
    _dragPosition = 0;
    _dragTotal = 0;
    _isDragging = false;
    _cardController.value = 0;
  }

  // Simplify to directly call _nextPrompt
  void _handleSwipe() {
    print("Swipe detected - calling _nextPrompt directly"); // Debug print
    _nextPrompt();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF7B1FA2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              
              // Main content
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background cards (deck effect)
                    if (!_showTutorial)
                      ...List.generate(2, (index) {
                        return Positioned(
                          top: 5.0 * (index + 1),
                          child: Transform.rotate(
                            angle: 0.05 * (index + 1),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.height * 0.6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8 - (index * 0.2)),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    
                    // Main card - Replace GestureDetector with new implementation
                    GestureDetector(
                      onTap: _nextPrompt,
                      onPanStart: (details) {
                        if (_isAnimating) return;
                        setState(() {
                          _isDragging = true;
                          _dragStartPosition = details.localPosition;
                          _dragPosition = 0;
                          _dragTotal = 0;
                        });
                      },
                      onPanUpdate: (details) {
                        if (_isAnimating || !_isDragging) return;
                        
                        final delta = (details.localPosition.dx - _dragStartPosition.dx) / 
                                     MediaQuery.of(context).size.width;
                        
                        setState(() {
                          _dragPosition = delta;
                          _dragPosition = _dragPosition.clamp(-1.0, 1.0);
                          _dragTotal += delta.abs();
                        });
                        
                        // Auto-advance if dragged enough - 30% threshold
                        if (_dragPosition.abs() > 0.3) {  // 30% of screen width
                          print("30% threshold reached - handling swipe"); // Debug print
                          _isDragging = false; // Prevent further updates
                          _handleSwipe();
                        }
                      },
                      onPanEnd: (details) {
                        if (_isAnimating || !_isDragging) return;
                        
                        _isDragging = false; // Prevent further updates
                        
                        // Only advance if dragged a minimum amount
                        if (_dragPosition.abs() > 0.1) {  // 10% of screen width
                          print("Pan end with sufficient drag - handling swipe"); // Debug print
                          _handleSwipe();
                        } else {
                          // Reset position if not swiped enough
                          setState(() {
                            _dragPosition = 0;
                            _dragTotal = 0;
                          });
                        }
                      },
                      child: Transform.translate(
                        offset: Offset(
                          _dragPosition * MediaQuery.of(context).size.width * 2.0,  // Increased multiplier for more dramatic movement
                          _dragPosition.abs() * -50,  // More upward movement as it's dragged
                        ),
                        child: Transform.rotate(
                          angle: _dragPosition * 0.8,  // More rotation for dramatic effect
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.height * 0.6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_showTutorial) ...[
                                        const Icon(
                                          Icons.swipe,
                                          size: 48,
                                          color: Color(0xFF1A237E),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Swipe or tap to start',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ] else if (_currentPromptIndex >= 0) ...[
                                        Text(
                                          _prompts[_currentPromptIndex].getFormattedText(
                                            _shuffledPlayers,
                                            targetPlayer: _currentTargetPlayer,  // Use stored player instead of generating new one
                                          ),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A237E),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                if (!_showTutorial)
                                  Positioned(
                                    bottom: 16,
                                    child: Text(
                                      'Swipe or tap to continue',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 