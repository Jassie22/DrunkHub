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
  
  // List of Gen Z-themed end screens
  final List<Map<String, dynamic>> _endScreens = [
    {
      'id': 'main_character',
      'title': 'Main Character Energy',
      'subtitle': 'The plot revolves around you now. Period.',
      'icon': '✨',
      'color': Colors.pink,
      'photoMessage': 'Take a pic for the TL!',
    },
    {
      'id': 'vibe_check',
      'title': 'Vibe Check: Passed',
      'subtitle': 'No cap, this sesh was actually bussin fr fr',
      'icon': '🔥',
      'color': Colors.orange,
      'photoMessage': 'Pics or it didn\'t happen!',
    },
    {
      'id': 'unhinged',
      'title': 'Certified Unhinged',
      'subtitle': 'Living your best chaotic era and we\'re here for it',
      'icon': '🤪',
      'color': Colors.purple,
      'photoMessage': 'Document this fever dream!',
    },
    {
      'id': 'core_memory',
      'title': 'Core Memory Unlocked',
      'subtitle': 'This night will live rent-free in your head',
      'icon': '🧠',
      'color': Colors.teal,
      'photoMessage': 'Photo dump material right here!',
    },
    {
      'id': 'glitch',
      'title': 'Simulation Glitch',
      'subtitle': 'The devs never expected you to get this far',
      'icon': '👾',
      'color': Colors.deepPurple,
      'photoMessage': 'Save proof before they patch this bug!',
    },
  ];
  
  // Selected end screen
  late Map<String, dynamic> _endScreen;

  @override
  void initState() {
    super.initState();
    
    // Set initialization flag immediately to show loading
    setState(() {
      _isInitialized = false;
      
      // Randomly select an end screen
      _endScreen = _endScreens[Random().nextInt(_endScreens.length)];
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
        // Background - dynamic gradient based on selected theme
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A237E), // Deep Blue base
                _endScreen['color'] as Color, // Theme color
                Colors.black.withOpacity(0.7), // Add depth
              ],
            ),
          ),
        ),
        
        // Theme-specific background element based on end screen ID
        if (_endScreen['id'] == 'main_character')
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.asset(
                'assets/images/icon.svg',
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  (_endScreen['color'] as Color).withOpacity(0.3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        if (_endScreen['id'] == 'glitch')
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                painter: GlitchPainter(),
              ),
            ),
          ),
        if (_endScreen['id'] == 'core_memory')
          ..._buildBubbles(),
        if (_endScreen['id'] == 'vibe_check')
          ..._buildFireEmojis(),
        if (_endScreen['id'] == 'unhinged')
          ..._buildChaosElements(),
        
        // Confetti - multiple sources with theme colors
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
            colors: [
              Colors.white, 
              _endScreen['color'] as Color,
              (_endScreen['color'] as Color).withOpacity(0.7),
              Colors.amber,
            ],
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
            colors: [
              Colors.white, 
              _endScreen['color'] as Color,
              Colors.blue,
            ],
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
            colors: [
              Colors.white, 
              _endScreen['color'] as Color,
              Colors.orange,
            ],
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

                    // Title with theme-specific styling
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              _endScreen['color'] as Color,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          _endScreen['title'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: _endScreen['id'] == 'glitch' ? -1 : 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                    _buildPlayerNames(),
                    
                    // Photo section
                    _buildPhotoSection(),
                    
                    // Buttons
                    _buildButtons(),
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
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return WillPopScope(
      onWillPop: () async {
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
        } catch (e) {
          debugPrint("Error stopping confetti: $e");
        }
        return true;
      },
      child: Scaffold(
        body: _buildEndScreen(),
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

  // Create floating bubbles for the core memory theme
  List<Widget> _buildBubbles() {
    final bubbles = <Widget>[];
    final random = Random();
    
    for (int i = 0; i < 15; i++) {
      final size = random.nextDouble() * 60 + 20;
      bubbles.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: random.nextInt(5) + 5),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(
                  10 * sin(value * 2 * pi),
                  -50 * value % MediaQuery.of(context).size.height,
                ),
                child: Opacity(
                  opacity: 0.4 - (0.2 * value),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          _endScreen['color'] as Color,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    return bubbles;
  }

  // Create floating fire emojis for vibe check theme
  List<Widget> _buildFireEmojis() {
    final emojis = <Widget>[];
    final random = Random();
    
    for (int i = 0; i < 10; i++) {
      final size = random.nextDouble() * 30 + 15;
      emojis.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          bottom: -20.0,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: random.nextInt(6) + 7),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(
                  5 * sin(value * 3 * pi),
                  -MediaQuery.of(context).size.height * value,
                ),
                child: Opacity(
                  opacity: 0.7 - (0.7 * value),
                  child: Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: size,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    return emojis;
  }

  // Create chaotic elements for the unhinged theme
  List<Widget> _buildChaosElements() {
    final elements = <Widget>[];
    final random = Random();
    final emojis = ['🤪', '💫', '🌀', '👁️', '💅', '✨', '💯', '🙃'];
    
    for (int i = 0; i < 20; i++) {
      final size = random.nextDouble() * 30 + 15;
      final emoji = emojis[random.nextInt(emojis.length)];
      elements.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 2 * pi),
            duration: Duration(seconds: random.nextInt(8) + 5),
            builder: (context, double value, child) {
              return Transform.rotate(
                angle: value,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: size,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    return elements;
  }

  // Build player names section
  Widget _buildPlayerNames() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (_endScreen['color'] as Color).withAlpha(51),
              Colors.white.withAlpha(51),
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
                  color: (_endScreen['color'] as Color).withAlpha(77),
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
    );
  }

  // Build photo section
  Widget _buildPhotoSection() {
    return Column(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              if (_groupPhoto != null) ...[
                // Photo with gradient decoration
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A237E),
                        _endScreen['color'] as Color,
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
                      
                      // Gradient footer with dynamic theme text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFF1A237E),
                              _endScreen['color'] as Color,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _endScreen['icon'],
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "DrunkHub",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
      ],
    );
  }

  // Build buttons
  Widget _buildButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
              child: Text(
                _getPlayAgainText(),
                style: const TextStyle(
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
    );
  }

  // Get theme-specific play again text
  String _getPlayAgainText() {
    switch (_endScreen['id']) {
      case 'main_character':
        return 'Next Episode';
      case 'vibe_check':
        return 'Keep the Vibe Going';
      case 'unhinged':
        return 'Get Even More Unhinged';
      case 'core_memory':
        return 'Make More Memories';
      case 'glitch':
        return 'Hack Again';
      default:
        return 'Play Again';
    }
  }
}

// Custom painter for glitch effect
class GlitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Draw random glitch rectangles
    for (int i = 0; i < 20; i++) {
      final left = random.nextDouble() * size.width;
      final top = random.nextDouble() * size.height;
      final width = random.nextDouble() * 100 + 20;
      final height = random.nextDouble() * 8 + 2;
      
      canvas.drawRect(
        Rect.fromLTWH(left, top, width, height),
        paint,
      );
    }
    
    // Draw some random lines
    for (int i = 0; i < 15; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + random.nextDouble() * 100 - 50;
      final endY = startY + random.nextDouble() * 20 - 10;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = random.nextDouble() * 2 + 1,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 