import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

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
    
    // Initialize with a delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeScreen();
    });
  }
  
  void _initializeScreen() {
    try {
      // Initialize controllers with shorter durations
      _confettiController = ConfettiController(duration: const Duration(milliseconds: 300));
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

      // Start animations with a delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _animationController.forward();
          
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _confettiController.play();
              
              setState(() {
                _isInitialized = true;
              });
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Error initializing GameEndScreen: $e");
      setState(() {
        _isInitialized = true; // Still mark as initialized to show fallback
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
        // Background - solid color
        Container(
          color: _endScreen['color'],
        ),
        
        // Confetti - minimal
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 2,
            minBlastForce: 1,
            emissionFrequency: 0.01,
            numberOfParticles: 5,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [Colors.white, Colors.blue, Colors.pink],
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
                    // Icon
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _endScreen['icon'],
                        style: const TextStyle(fontSize: 50),
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

                    // Player Names - simplified
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(16),
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

                    // Photo Section - simplified
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          if (_groupPhoto != null) ...[
                            // Photo with minimal decoration
                            Container(
                              width: double.infinity,
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
                                  
                                  // Simple footer
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1A237E),
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

                    // Action Buttons - simplified
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1A237E),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
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
          if (_animationController.isAnimating) {
            _animationController.stop();
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
      
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      _animationController.dispose();
    } catch (e) {
      debugPrint("Error disposing controllers: $e");
    }
    super.dispose();
  }
} 