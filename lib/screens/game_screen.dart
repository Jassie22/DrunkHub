import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/game_prompt.dart';
import '../models/game_package.dart';
import 'game_end_screen.dart';

class GameScreen extends StatefulWidget {
  final List<String> players;
  final List<GamePackage> selectedPackages;
  final bool quickDrinkMode;

  const GameScreen({
    super.key,
    required this.players,
    required this.selectedPackages,
    required this.quickDrinkMode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<GamePrompt> _prompts;
  late List<String> _shuffledPlayers;
  int _currentPromptIndex = -1;
  bool _showTutorial = true;
  static const int maxPrompts = 10;
  String? _currentTargetPlayer;
  bool _isInitialized = false;
  
  // Quick drink mode variables
  bool _showQuickDrink = false;
  int _quickDrinkCountdown = 3;
  Timer? _quickDrinkTimer;
  Timer? _quickDrinkPopupTimer;
  
  late AnimationController _rattleController;
  late Animation<double> _rattleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup basic animation controller
    _rattleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _rattleAnimation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(
      CurvedAnimation(
        parent: _rattleController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Delay full initialization to prevent frame drops
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _initializeGame();
        
        if (_showTutorial) {
          _rattleController.repeat(reverse: true, period: const Duration(milliseconds: 800));
        }
        
        setState(() {
          _isInitialized = true;
        });
        
        // Schedule quick drink popups if enabled
        if (widget.quickDrinkMode && !_showTutorial) {
          _scheduleQuickDrinkPopup();
        }
      }
    });
  }

  void _initializeGame() {
    try {
      // Generate a smaller set of prompts
      _prompts = GamePrompt.generatePromptsFromPackages(widget.selectedPackages);
      _prompts.shuffle();
      
      if (_prompts.length > maxPrompts) {
        _prompts = _prompts.sublist(0, maxPrompts);
      }
      
      _shuffledPlayers = List.from(widget.players);
      _shuffledPlayers.shuffle();
    } catch (e) {
      debugPrint("Error initializing game: $e");
    }
  }

  void _scheduleQuickDrinkPopup() {
    // Random time between 30 seconds and 2 minutes
    final randomSeconds = Random().nextInt(90) + 30;
    _quickDrinkPopupTimer = Timer(Duration(seconds: randomSeconds), () {
      if (mounted) {
        _showQuickDrinkAlert();
      }
    });
  }
  
  void _showQuickDrinkAlert() {
    // Vibrate the phone
    HapticFeedback.heavyImpact();
    
    setState(() {
      _showQuickDrink = true;
      _quickDrinkCountdown = 3;
    });
    
    // Start countdown timer
    _quickDrinkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_quickDrinkCountdown > 0) {
        setState(() {
          _quickDrinkCountdown--;
        });
        HapticFeedback.mediumImpact();
      } else {
        _quickDrinkTimer?.cancel();
        HapticFeedback.heavyImpact();
        
        // Hide the overlay after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showQuickDrink = false;
            });
            
            // Schedule the next popup
            _scheduleQuickDrinkPopup();
          }
        });
      }
    });
  }

  String _getRandomPlayer({String? exclude}) {
    if (_shuffledPlayers.isEmpty) return "Player";
    
    List<String> availablePlayers = exclude != null ? 
      _shuffledPlayers.where((p) => p != exclude).toList() : 
      _shuffledPlayers;
      
    if (availablePlayers.isEmpty) return "Player";
    return availablePlayers[Random().nextInt(availablePlayers.length)];
  }

  void _nextPrompt() {
    if (!_isInitialized || _showQuickDrink) return;
    
    setState(() {
      if (_showTutorial) {
        _showTutorial = false;
        _currentPromptIndex = 0;
        _rattleController.stop();
        
        // Start scheduling quick drink popups after tutorial
        if (widget.quickDrinkMode) {
          _scheduleQuickDrinkPopup();
        }
      } else {
        if (_currentPromptIndex >= _prompts.length - 1) {
          _endGame();
          return;
        }
        _currentPromptIndex++;
      }
      _currentTargetPlayer = _getRandomPlayer();
    });
  }

  @override
  void dispose() {
    try {
      if (_rattleController.isAnimating) {
        _rattleController.stop();
      }
      _rattleController.dispose();
      _quickDrinkTimer?.cancel();
      _quickDrinkPopupTimer?.cancel();
    } catch (e) {
      debugPrint("Error disposing controllers: $e");
    }
    super.dispose();
  }

  void _endGame() {
    try {
      if (_rattleController.isAnimating) {
        _rattleController.stop();
      }
      
      _quickDrinkTimer?.cancel();
      _quickDrinkPopupTimer?.cancel();
      
      // Use a simpler navigation approach
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameEndScreen(
            players: widget.players,
            onPlayAgain: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    players: widget.players,
                    selectedPackages: widget.selectedPackages,
                    quickDrinkMode: widget.quickDrinkMode,
                  ),
                ),
              );
            },
            onNewGame: () {
              Navigator.of(context).pop();
            },
            onHome: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error showing end game screen: $e");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Clean up before popping
        if (_rattleController.isAnimating) {
          _rattleController.stop();
        }
        _quickDrinkTimer?.cancel();
        _quickDrinkPopupTimer?.cancel();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content
            Container(
              color: const Color(0xFF1A237E),
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
                    
                    Center(
                      child: _isInitialized 
                        ? (_showTutorial 
                            ? _buildTutorialCard() 
                            : _buildGameCard())
                        : const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Quick drink overlay
            if (_showQuickDrink)
              GestureDetector(
                onTap: () {}, // Prevent taps from passing through
                child: Container(
                  color: Colors.red.withAlpha(204),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'DRINK NOW!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '$_quickDrinkCountdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTutorialCard() {
    return GestureDetector(
      onTap: _nextPrompt,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rattleAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rattleAnimation.value,
                      child: const Icon(
                        Icons.swipe,
                        size: 40,
                        color: Color(0xFF1A237E),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to DrunkHub!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Tap to play drinking games with friends',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.quickDrinkMode) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withAlpha(77)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Quick Drink Mode is ON! Be ready for surprise drink alerts!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _nextPrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameCard() {
    if (_currentPromptIndex < 0 || _currentPromptIndex >= _prompts.length) {
      return const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ));
    }
    
    return GestureDetector(
      onTap: _nextPrompt,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
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
                  Text(
                    _prompts[_currentPromptIndex].getFormattedText(
                      _shuffledPlayers,
                      targetPlayer: _currentTargetPlayer,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            Positioned(
              bottom: 16,
              child: Text(
                'Tap to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 