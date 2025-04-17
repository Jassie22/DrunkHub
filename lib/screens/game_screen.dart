import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/game_prompt.dart';
import '../models/game_package.dart';
import 'game_end_screen.dart';

class GameScreen extends StatefulWidget {
  final List<String> players;
  final List<GameMode> selectedModes;
  final bool quickDrinkMode;

  const GameScreen({
    super.key,
    required this.players,
    required this.selectedModes,
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
  static const int maxPrompts = 5;
  String? _currentTargetPlayer;
  bool _isInitialized = false;
  
  // Drink mode variables - changed to be prompt-based instead of time-based
  List<int> _drinkPromptIndices = []; // Store multiple indices for drink prompts
  bool _showQuickDrink = false;
  bool _drinkModeAlreadyTriggered = false; // Track if drink mode has already been triggered
  int _quickDrinkCountdown = 5;
  Timer? _quickDrinkTimer;
  
  // Audio player for sound effects
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false; // Track mute state
  
  // Animation controllers
  late AnimationController _rattleController;
  late Animation<double> _rattleAnimation;
  
  // Card slide animation
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideLeftAnimation;
  bool _isAnimating = false;
  bool _isAnimatingLeft = false;
  Offset _dragStart = Offset.zero;
  Offset _dragUpdate = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _rattleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _rattleAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _rattleController,
        curve: Curves.bounceInOut,
      ),
    );
    
    // Setup slide right animation
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(
      CurvedAnimation(
        parent: _rattleController,
        curve: Curves.easeOut,
      ),
    );
    
    // Setup slide left animation
    _slideLeftAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0),
    ).animate(
      CurvedAnimation(
        parent: _rattleController,
        curve: Curves.easeOut,
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
      }
    });
  }

  void _initializeGame() {
    try {
      // Generate a set of prompts from selected game modes
      if (widget.selectedModes.isEmpty) {
        debugPrint('Warning: No game modes selected. Adding fallback mode.');
        // Add the Getting Started game mode as fallback
        final fallbackMode = gameModes.firstWhere(
          (mode) => mode.id == 'getting_started',
          orElse: () => GameMode(
            id: 'fallback',
            name: 'Fallback Mode',
            description: 'Basic drinking game',
            icon: '🎮',
            isPremium: false,
            category: 'Warm-Up (Free)',
            samplePrompts: [
              'Take a sip if you\'re playing this game!',
              'Everyone take a drink to get started!',
              'Choose someone to take a drink with you',
              'Last person to touch their nose drinks',
              'Everyone wearing jeans drinks',
            ],
          ),
        );
        _prompts = GamePrompt.generatePromptsFromGameModes([fallbackMode]);
      } else {
        _prompts = GamePrompt.generatePromptsFromGameModes(widget.selectedModes);
      }
      
      // Safety check - ensure we have some prompts
      if (_prompts.isEmpty) {
        debugPrint('Warning: No prompts generated. Adding fallback prompts.');
        _prompts = [
          GamePrompt(text: 'Take a sip if you\'re playing this game!'),
          GamePrompt(text: 'Everyone take a drink to get started!', isGroupPrompt: true),
          GamePrompt(text: 'Choose someone to take a drink with you'),
          GamePrompt(text: 'Last person to touch their nose drinks'),
          GamePrompt(text: 'Everyone wearing jeans drinks', isGroupPrompt: true),
        ];
      }
      
      _prompts.shuffle();
      
      if (_prompts.length > maxPrompts) {
        _prompts = _prompts.sublist(0, maxPrompts);
      }
      
      _shuffledPlayers = List.from(widget.players);
      // Safety check - ensure we have some players
      if (_shuffledPlayers.isEmpty) {
        _shuffledPlayers = ['Player 1', 'Player 2'];
      }
      _shuffledPlayers.shuffle();
      
      // Reset game state
      _currentPromptIndex = -1;
      _drinkModeAlreadyTriggered = false;
      
      // Choose random prompts to activate drink mode (excluding the first quarter of prompts and the last prompt)
      if (_prompts.length > 1 && widget.quickDrinkMode) {
        _drinkPromptIndices = [];
        
        // Determine the range for possible drink prompts (first quarter to second-to-last card)
        int startIndex = (_prompts.length * 0.25).ceil(); // Start after first quarter
        int endIndex = _prompts.length - 2; // End before the last card
        
        // Make sure we have a valid range
        if (startIndex <= endIndex) {
          // Determine how many drink prompts to show based on total prompts
          int drinkCount = min(2, (endIndex - startIndex + 1));
          
          // Create a list of available indices (within our valid range)
          List<int> availableIndices = List.generate(endIndex - startIndex + 1, (i) => i + startIndex);
          availableIndices.shuffle();
          
          // Select random indices
          for (int i = 0; i < drinkCount; i++) {
            if (availableIndices.isNotEmpty) {
              _drinkPromptIndices.add(availableIndices.removeAt(0));
            }
          }
          
          // Sort them so we can check in order
          _drinkPromptIndices.sort();
          debugPrint('Sudden drink will appear at indices: $_drinkPromptIndices');
        } else {
          debugPrint('Not enough cards to place sudden drink prompts');
        }
      } else {
        _drinkPromptIndices = [];
      }
    } catch (e) {
      debugPrint("Error initializing game: $e");
      // Recovery mechanism
      _prompts = [
        GamePrompt(text: 'Take a sip if you\'re playing this game!'),
        GamePrompt(text: 'Everyone take a drink to get started!', isGroupPrompt: true),
        GamePrompt(text: 'Choose someone to take a drink with you'),
      ];
      _shuffledPlayers = widget.players.isNotEmpty ? List.from(widget.players) : ['Player 1', 'Player 2'];
      _currentPromptIndex = -1;
    }
  }
  
  void _showQuickDrinkAlert() {
    // Much stronger haptic feedback sequence
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.heavyImpact();
      });
    });
    
    // Play alarm sound if not muted
    if (!_isMuted) {
      try {
        // Play system alert sound multiple times for emphasis
        SystemSound.play(SystemSoundType.alert);
        
        // Try to play buzzer sound multiple times to create an alarm effect
        Future.delayed(const Duration(milliseconds: 200), () {
          SystemSound.play(SystemSoundType.alert);
        });
        
        Future.delayed(const Duration(milliseconds: 400), () {
          SystemSound.play(SystemSoundType.alert);
        });
        
        // Try audio player as fallback
        _audioPlayer.play(AssetSource('audio/drink_alarm.mp3'), volume: 1.0)
          .catchError((error) {
            debugPrint('Error playing custom audio: $error');
          });
      } catch (e) {
        debugPrint('Exception playing audio: $e');
        // Try an alternative approach
        SystemChannels.platform.invokeMethod('SystemSound.play', 'SystemSoundType.alert');
      }
    } else {
      debugPrint('Audio muted, not playing alert sounds');
    }
    
    // Start shaking the screen more rapidly and aggressively
    _rattleController.stop(); // Stop any existing animation
    _rattleController.reset();
    _rattleController.repeat(reverse: true, period: const Duration(milliseconds: 120)); // Faster shake
    
    setState(() {
      _showQuickDrink = true;
      _quickDrinkCountdown = 5; // Increased from 3 to 5 seconds
    });
    
    // Start countdown timer
    _quickDrinkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_quickDrinkCountdown > 0) {
        setState(() {
          _quickDrinkCountdown--;
        });
        HapticFeedback.mediumImpact();
        
        // Play tick sound for each countdown if not muted
        if (!_isMuted) {
          SystemSound.play(SystemSoundType.click);
        }
      } else {
        _endQuickDrink();
      }
    });
  }
  
  // New method to handle ending the quick drink alert
  void _endQuickDrink() {
        _quickDrinkTimer?.cancel();
        HapticFeedback.heavyImpact();
    
    // Stop shaking
    _rattleController.stop();
    _rattleController.reset();
        
        // Hide the overlay after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showQuickDrink = false;
        });
      }
    });
  }
  
  // Skip the quick drink
  void _skipQuickDrink() {
    _quickDrinkTimer?.cancel();
    
    // Stop shaking
    _rattleController.stop();
    _rattleController.reset();
    
    // Hide the overlay immediately
    setState(() {
      _showQuickDrink = false;
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
    // Safety check - don't proceed if we're not ready
    if (!_isInitialized || _showQuickDrink || _isAnimating || _isAnimatingLeft) return;
    
    try {
    setState(() {
      if (_showTutorial) {
        _showTutorial = false;
        _currentPromptIndex = 0;
        _rattleController.stop();
        } else {
          _animateCardSwipe(isLeft: false);
        }
      });
    } catch (e) {
      debugPrint("Error in _nextPrompt: $e");
      // Recovery mechanism
      if (mounted) {
        setState(() {
          _showTutorial = false;
          _currentPromptIndex = 0;
        });
      }
    }
  }
  
  void _animateCardSwipe({required bool isLeft}) {
    if (_isAnimating || _isAnimatingLeft) return;
    
    setState(() {
      if (isLeft) {
        _isAnimatingLeft = true;
      } else {
      _isAnimating = true;
      }
    });
    
    // Reset controller for slide animation
    _rattleController.reset();
    
    // Animate the card sliding out
    _rattleController.forward().then((_) {
      if (mounted) {
        setState(() {
          try {
          if (_currentPromptIndex >= _prompts.length - 1) {
              // We're at the last prompt, trigger end game
              Future.microtask(() => _endGame());
            return;
          }
          _currentPromptIndex++;
            
            // Check if the current index is in our drink prompt indices list
            // AND if drink mode hasn't already been triggered in this game session
            if (widget.quickDrinkMode && 
                !_drinkModeAlreadyTriggered && 
                _drinkPromptIndices.contains(_currentPromptIndex)) {
              // Start quick drink mode on this prompt
              _drinkModeAlreadyTriggered = true; // Mark as triggered
              _showQuickDrinkAlert();
              // Remove this index so it doesn't trigger again if we revisit it
              _drinkPromptIndices.remove(_currentPromptIndex);
            }
            
            _currentTargetPlayer = _getRandomPlayer();
          } catch (e) {
            debugPrint('Error during card animation: $e');
            // If we encounter an error, try to recover
            if (_currentPromptIndex >= _prompts.length - 1) {
              Future.microtask(() => _endGame());
            } else {
              _currentPromptIndex = min(_currentPromptIndex + 1, _prompts.length - 1);
          _currentTargetPlayer = _getRandomPlayer();
            }
          } finally {
          _isAnimating = false;
            _isAnimatingLeft = false;
            // Reset the drag position so the next card appears in the middle
            _dragUpdate = Offset.zero;
            debugPrint('Card reset to center: $_dragUpdate');
          }
        });
      }
    });
  }
  
  void _handleSwipe(DragUpdateDetails details) {
    if (_showTutorial || _isAnimating || _isAnimatingLeft) return;
    
    setState(() {
      _dragUpdate = details.localPosition - _dragStart;
    });
  }
  
  void _handleSwipeEnd(DragEndDetails details) {
    if (_showTutorial || _isAnimating || _isAnimatingLeft) return;
    
    // If swiped far enough to the right, go to next prompt
    if (_dragUpdate.dx > 100) {
      _animateCardSwipe(isLeft: false);
    } 
    // If swiped far enough to the left, also go to next prompt
    else if (_dragUpdate.dx < -100) {
      _animateCardSwipe(isLeft: true);
    } 
    // Reset position if not swiped far enough
    else {
      setState(() {
        _dragUpdate = Offset.zero;
      });
    }
  }

  @override
  void dispose() {
    _quickDrinkTimer?.cancel();
      _rattleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _endGame() {
    if (_isAnimating || _isAnimatingLeft) return; // Don't trigger if already animating
    
    // Immediately disable animations to prevent multiple calls
    _isAnimating = true;
    _isAnimatingLeft = true;
    
    try {
      // Stop any ongoing animations and cancel timers
      if (_rattleController.isAnimating) {
        _rattleController.stop();
      }
      if (_quickDrinkTimer != null) {
        _quickDrinkTimer!.cancel();
        _quickDrinkTimer = null;
      }
      
      // Navigate to end screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameEndScreen(
            players: widget.players,
            onPlayAgain: () {
              // Pop end screen
              Navigator.of(context).pop();
              
              // Replace current game screen with a new one with the same settings
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    players: widget.players,
                    selectedModes: widget.selectedModes,
                    quickDrinkMode: widget.quickDrinkMode,
                  ),
                ),
              );
            },
            onNewGame: () {
              // Go back to game selection
              Navigator.of(context).pop(); // Pop end screen
              Navigator.of(context).pop(); // Pop game screen
              // Don't pop the game selection screen - this keeps the user on the game selection page
              // Navigation stack after this: Home -> Game Selection (current)
            },
            onHome: () {
              // Go back to game selection (not home)
              Navigator.of(context).pop(); // Pop end screen
              Navigator.of(context).pop(); // Pop game screen
              // Don't pop the game selection screen - this keeps the user on the game selection page
              // Navigation stack after this: Home -> Game Selection (current)
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error in end game: $e');
    } finally {
      _isAnimating = false;
      _isAnimatingLeft = false;
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
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A237E), // Deep Blue
                    Color(0xFF7B1FA2), // Purple
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    
                    // Mute button
                    Positioned(
                      top: 16,
                      right: 16, // Move to right edge since logo is removed
                      child: IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                        tooltip: _isMuted ? 'Unmute sound' : 'Mute sound',
                      ),
                    ),
                    
                    // App logo removed
                    
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
              AnimatedBuilder(
                animation: _rattleController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_rattleAnimation.value * 25, 0), // Increased shake amount
                    child: GestureDetector(
                onTap: () {}, // Prevent taps from passing through
                child: Container(
                        decoration: BoxDecoration(
                          // Gradient background instead of flat color
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red.shade900,
                              Colors.red.shade800,
                              Colors.red.shade700,
                            ],
                          ),
                        ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                              // Animated icon for attention
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF7B1FA2).withOpacity(0.8),
                                      Color(0xFF1A237E).withOpacity(0.9),
                                    ],
                                  ),
                                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_bar_rounded,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Colors.white, Colors.white.withOpacity(0.85)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                                child: const Text(
                                  'DRINK ROULETTE!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 44, 
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                    fontFamily: 'Roboto',
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black45,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFF5F5F5),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(22),
                                child: Text(
                                  '$_quickDrinkCountdown',
                                  style: TextStyle(
                                    color: Color(0xFF7B1FA2),
                                    fontSize: 96,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Instructions for drink
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 32),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                ),
                                child: const Text(
                                  'Take a drink or pay the price!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                    shadows: [Shadow(
                                      color: Colors.black38,
                                      blurRadius: 3,
                                      offset: Offset(1, 1),
                                    )],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Skip button
                              TextButton(
                                onPressed: _skipQuickDrink,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'SKIP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                    ),
                  );
                },
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
        height: MediaQuery.of(context).size.height * 0.65, // Taller card
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5),
            ],
          ),
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
                    'Swipe left or right to play drinking games with friends',
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
                      color: Color(0xFF7B1FA2).withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF7B1FA2).withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF7B1FA2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.sports_bar_rounded, 
                            color: Color(0xFF7B1FA2), 
                            size: 18
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Drink Roulette is active! Random drinks will appear during gameplay.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7B1FA2),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
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
    // Safety check - make sure we have valid indices
    if (_currentPromptIndex < 0 || _prompts.isEmpty || _currentPromptIndex >= _prompts.length) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Loading game...", style: TextStyle(color: Color(0xFF1A237E))),
              ],
            ),
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: _nextPrompt,
      onHorizontalDragStart: (details) {
        _dragStart = details.localPosition;
      },
      onHorizontalDragUpdate: _handleSwipe,
      onHorizontalDragEnd: _handleSwipeEnd,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          // Apply the appropriate animation based on direction
          final Offset offset;
          if (_isAnimatingLeft) {
            offset = _slideLeftAnimation.value;
          } else if (_isAnimating) {
            offset = _slideAnimation.value;
          } else {
            // Handle manual dragging
            offset = Offset(_dragUpdate.dx / 200, 0);
          }
          
          return Transform.translate(
            offset: Offset(offset.dx * 200, 0),
            child: Transform.rotate(
              angle: offset.dx * 0.2, // Slight rotation while sliding
              child: child,
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.65, // Taller, more rectangular card
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
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1.0,
            ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.swipe,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe left/right or tap to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
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