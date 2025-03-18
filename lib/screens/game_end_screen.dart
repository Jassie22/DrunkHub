import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../utils/app_assets.dart';

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
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  File? _groupPhoto;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // Super simplified end screens - just one option
  final Map<String, dynamic> _endScreen = {
    'id': 'legendary',
    'title': 'Legendary Night',
    'subtitle': 'This Night Has Entered the Hall of Fame',
    'icon': '🌟',
    'color': Colors.amber,
    'photoMessage': 'Document this legendary moment!',
  };

  @override
  void initState() {
    super.initState();
    
    // Set initialization flag immediately to show loading
    setState(() {
      _isInitialized = false;
    });
    
    try {
      _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

      // Initialize confetti controllers with shorter duration
      _confettiController = ConfettiController(duration: const Duration(seconds: 3));
      _confettiControllerLeft = ConfettiController(duration: const Duration(seconds: 3));
      _confettiControllerRight = ConfettiController(duration: const Duration(seconds: 3));

      // Start animations with delays
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _fadeController.forward();
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            _confettiController.play();
            _confettiControllerLeft.play();
            _confettiControllerRight.play();
            
            // Set initialized to true after confetti starts
            setState(() {
              _isInitialized = true;
            });
          } catch (e) {
            debugPrint('Error playing confetti: $e');
            // Still mark as initialized even if confetti fails
            setState(() {
              _isInitialized = true;
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Error initializing game end screen: $e');
      // Set initialized to true even on error
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
    }
  }

  Future<void> _takeGroupPhoto() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 600,
      );

      if (!mounted) return;

      if (photo != null) {
        setState(() {
          _groupPhoto = File(photo.path);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error taking photo: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sharePhoto() async {
    try {
      if (_groupPhoto != null) {
        await Share.shareXFiles(
          [XFile(_groupPhoto!.path)], 
          text: 'Check out our DrunkHub game night! 🎉'
        );
      }
    } catch (e) {
      debugPrint("Error sharing photo: $e");
    }
  }

  Widget _buildEndScreen() {
    return Stack(
      children: [
        // Background - gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E), // Deep Blue
                Color(0xFF7B1FA2), // Purple
                Colors.amber,
              ],
            ),
          ),
        ),
        
        // Confetti - multiple sources
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 7,
            minBlastForce: 3,
            emissionFrequency: 0.03,
            numberOfParticles: 10,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [Colors.white, Colors.blue, Colors.pink, Colors.amber, Colors.purple],
            child: const SizedBox(),
          ),
        ),
        
        // Left side confetti
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _confettiControllerLeft,
            blastDirection: pi / 4, // 45 degrees
            emissionFrequency: 0.02,
            numberOfParticles: 5,
            maxBlastForce: 6,
            minBlastForce: 3,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [Colors.white, Colors.blue, Colors.green, Colors.yellow],
            child: const SizedBox(),
          ),
        ),
        
        // Right side confetti
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _confettiControllerRight,
            blastDirection: 3 * pi / 4, // 135 degrees
            emissionFrequency: 0.02,
            numberOfParticles: 5,
            maxBlastForce: 6,
            minBlastForce: 3,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [Colors.white, Colors.red, Colors.orange, Colors.purple],
            child: const SizedBox(),
          ),
        ),

        // Content
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon and title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _endScreen['icon'],
                            style: const TextStyle(fontSize: 50),
                          ),
                          const SizedBox(width: 15),
                          AppAssets.getAppIconSvg(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _endScreen['title'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _endScreen['subtitle'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Player Names - with gradient
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withAlpha(51),
                              Colors.purple.withAlpha(51),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Players',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: widget.players.map((player) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(77),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  player,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photo Section - with gradient frame
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          if (_groupPhoto != null) ...[
                            // Photo with gradient decoration
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1A237E),
                                    Color(0xFF7B1FA2),
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
                              child: Column(
                                children: [
                                  // Photo
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: AspectRatio(
                                        aspectRatio: 4/3,
                                        child: Image.file(
                                          _groupPhoto!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Gradient footer
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF1A237E),
                                          Color(0xFF7B1FA2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "DrunkHub 🍻",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Single button for sharing
                            ElevatedButton.icon(
                              onPressed: _sharePhoto,
                              icon: const Icon(Icons.share, size: 16),
                              label: const Text('Share Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ] else
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _takeGroupPhoto,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt, size: 16),
                              label: Text(_isLoading ? 'Taking Photo...' : _endScreen['photoMessage']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons - with gradient
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: widget.onPlayAgain,
                              child: const Text(
                                'Play Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: widget.onNewGame,
                                child: const Text(
                                  'New Game',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: widget.onHome,
                                child: const Text(
                                  'Home',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Clean up before popping
        try {
          if (_confettiController.state == ConfettiControllerState.playing) {
            _confettiController.stop();
          }
          if (_confettiControllerLeft.state == ConfettiControllerState.playing) {
            _confettiControllerLeft.stop();
          }
          if (_confettiControllerRight.state == ConfettiControllerState.playing) {
            _confettiControllerRight.stop();
          }
          if (_fadeController.isAnimating) {
            _fadeController.stop();
          }
        } catch (e) {
          debugPrint("Error on back press: $e");
        }
      },
      child: Scaffold(
        body: _isInitialized 
          ? _buildEndScreen()
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      if (_confettiController.state == ConfettiControllerState.playing) {
        _confettiController.stop();
      }
      _confettiController.dispose();
      
      if (_confettiControllerLeft.state == ConfettiControllerState.playing) {
        _confettiControllerLeft.stop();
      }
      _confettiControllerLeft.dispose();
      
      if (_confettiControllerRight.state == ConfettiControllerState.playing) {
        _confettiControllerRight.stop();
      }
      _confettiControllerRight.dispose();
      
      if (_fadeController.isAnimating) {
        _fadeController.stop();
      }
      _fadeController.dispose();
    } catch (e) {
      debugPrint("Error disposing controllers: $e");
    }
    super.dispose();
  }
} 