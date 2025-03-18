import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _GameEndScreenState extends State<GameEndScreen> with TickerProviderStateMixin {
  // Remove all confetti-related variables
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  File? _groupPhoto;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // List of Gen Z-themed end screens
  final List<Map<String, dynamic>> _endScreens = [
    // Free end screens (4)
    {
      'id': 'main_character',
      'title': 'Main Character Energy',
      'subtitle': 'The plot revolves around you now. Period.',
      'icon': '✨',
      'color': Colors.pink,
      'photoMessage': 'Take a pic for the TL!',
      'isPremium': false,
    },
    {
      'id': 'vibe_check',
      'title': 'Vibe Check: Passed',
      'subtitle': 'No cap, this sesh was actually bussin fr fr',
      'icon': '🔥',
      'color': Colors.orange,
      'photoMessage': 'Pics or it didn\'t happen!',
      'isPremium': false,
    },
    {
      'id': 'unhinged',
      'title': 'Certified Unhinged',
      'subtitle': 'Living your best chaotic era and we\'re here for it',
      'icon': '🤪',
      'color': Colors.purple,
      'photoMessage': 'Document this fever dream!',
      'isPremium': false,
    },
    {
      'id': 'core_memory',
      'title': 'Core Memory Unlocked',
      'subtitle': 'This night will live rent-free in your head',
      'icon': '🧠',
      'color': Colors.teal,
      'photoMessage': 'Photo dump material right here!',
      'isPremium': false,
    },
    
    // Premium end screens (7)
    {
      'id': 'glitch',
      'title': 'Simulation Glitch',
      'subtitle': 'The devs never expected you to get this far',
      'icon': '👾',
      'color': Colors.deepPurple,
      'photoMessage': 'Save proof before they patch this bug!',
      'isPremium': true,
    },
    {
      'id': 'slay',
      'title': 'Absolutely Slayed',
      'subtitle': 'You ate and left no crumbs. Periodt.',
      'icon': '💅',
      'color': Colors.red.shade700,
      'photoMessage': 'Capture the slay!',
      'isPremium': true,
    },
    {
      'id': 'rizz',
      'title': 'Rizz Overload',
      'subtitle': 'Your collective rizz is too powerful. It\'s wild out here.',
      'icon': '😏',
      'color': Colors.blue.shade600,
      'photoMessage': 'Immortalize the rizz!',
      'isPremium': true,
    },
    {
      'id': 'based',
      'title': 'Based Behavior',
      'subtitle': 'That was low-key the most based thing ever, no 🧢',
      'icon': '💯',
      'color': Colors.green.shade800,
      'photoMessage': 'Snap this W!',
      'isPremium': true,
    },
    // New premium end screens to reach a total of 7
    {
      'id': 'iconic',
      'title': 'Iconic Moment',
      'subtitle': 'This is the moment everyone will reference for years',
      'icon': '👑',
      'color': Colors.amber.shade700,
      'photoMessage': 'Capture this historic moment!',
      'isPremium': true,
    },
    {
      'id': 'cursed',
      'title': 'Cursed Timeline',
      'subtitle': 'The collective chaos has altered reality. Welcome to the dark timeline.',
      'icon': '🌚',
      'color': Colors.indigo.shade900,
      'photoMessage': 'Document the evidence!',
      'isPremium': true,
    },
    {
      'id': 'plot_twist',
      'title': 'Ultimate Plot Twist',
      'subtitle': 'Nobody saw this coming. Not even the writers.',
      'icon': '🔄',
      'color': Colors.cyan.shade700,
      'photoMessage': 'Capture the twist!',
      'isPremium': true,
    },
  ];
  
  // Premium status (should be passed in from game screen in a real app)
  bool _isPremiumUser = false;
  
  // Selected end screen
  late Map<String, dynamic> _endScreen;

  @override
  void initState() {
    super.initState();
    
    // Set initialization flag immediately to show loading
    setState(() {
      _isInitialized = false;
      
      // Check premium status (this would be passed from the parent in a real app)
      _loadPremiumStatus();
      
      // Filter screens based on premium status
      final availableScreens = _getAvailableEndScreens();
      
      // Randomly select an end screen from available ones
      _endScreen = availableScreens[Random().nextInt(availableScreens.length)];
    });
    
    try {
      // Fade animations for content
      _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _fadeAnimation = CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      );

      // Pulse animation for emoji
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _pulseAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 0.9)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.9, end: 1.2)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20,
        ),
      ]).animate(_pulseController);
      
      // Start pulse animation and repeat
      _pulseController.repeat();

      // Start animations and mark as initialized
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _fadeController.forward();
          setState(() {
            _isInitialized = true;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing end screen: $e');
      setState(() {
        _isInitialized = true;
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
        if (_endScreen['id'] == 'slay')
          ..._buildSlayElements(),
        if (_endScreen['id'] == 'rizz')
          ..._buildRizzElements(),
        if (_endScreen['id'] == 'based')
          ..._buildBasedElements(),
        if (_endScreen['id'] == 'core_memory')
          ..._buildBubbles(),
        if (_endScreen['id'] == 'vibe_check')
          ..._buildFireEmojis(),
        if (_endScreen['id'] == 'unhinged')
          ..._buildChaosElements(),
        
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
                    // Icon with pulse animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Text(
                                _endScreen['icon'],
                                style: const TextStyle(fontSize: 70),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title with improved gradient
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.9),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0.0, 0.9],
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
                    
                    // Buttons - with Back instead of Home
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
      // Dispose animations
      if (_fadeController.isAnimating) {
        _fadeController.stop();
      }
      _fadeController.dispose();
      
      // Dispose pulse controller
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
      _pulseController.dispose();
    } catch (e) {
      debugPrint("Error disposing controllers: $e");
    }
    super.dispose();
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

  // Build photo section with thinner banner
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
                                  
                      // Thinner banner with just the icon and DrunkHub text
                                  Container(
                                    width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4), // Reduced vertical padding
                        decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                              const Color(0xFF1A237E).withOpacity(0.8), // More transparent
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
                              style: const TextStyle(fontSize: 14), // Smaller icon
                            ),
                            const SizedBox(width: 4), // Less spacing
                            const Text(
                              "DrunkHub",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                fontSize: 12, // Smaller text
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

  // Build buttons - replace Home with Back
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
          TextButton.icon(
            onPressed: () {
              // Go back to game selection instead of home
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
            label: const Text(
              'Back to Selection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
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

  // Create elements for new "Slay" theme
  List<Widget> _buildSlayElements() {
    final elements = <Widget>[];
    final random = Random();
    final emojis = ['💅', '💄', '👑', '💋', '💎', '✨'];
    
    for (int i = 0; i < 15; i++) {
      final size = random.nextDouble() * 30 + 15;
      final emoji = emojis[random.nextInt(emojis.length)];
      elements.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: random.nextInt(5) + 3),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  sin(value * 3 * pi) * 15,
                ),
                child: Transform.rotate(
                  angle: sin(value * pi) * 0.2,
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: size,
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
    
    return elements;
  }

  // Create elements for new "Rizz" theme
  List<Widget> _buildRizzElements() {
    final elements = <Widget>[];
    final random = Random();
    final emojis = ['😏', '💘', '🤙', '👀', '💌', '🫰'];
    
    for (int i = 0; i < 15; i++) {
      final size = random.nextDouble() * 30 + 15;
      final emoji = emojis[random.nextInt(emojis.length)];
      elements.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: random.nextInt(6) + 4),
            builder: (context, double value, child) {
              // Sliding from side with bounce effect
              final xOffset = (1 - value) * MediaQuery.of(context).size.width * 0.5 * (random.nextBool() ? 1 : -1);
              final yOffset = sin(value * 2 * pi) * 20;
              
              return Transform.translate(
                offset: Offset(xOffset, yOffset),
                child: Opacity(
                  opacity: 0.7,
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

  // Create elements for new "Based" theme
  List<Widget> _buildBasedElements() {
    final elements = <Widget>[];
    final random = Random();
    final emojis = ['💯', '🔥', '👌', '🙌', '📈', '🏆'];
    
    for (int i = 0; i < 15; i++) {
      final size = random.nextDouble() * 30 + 15;
      final emoji = emojis[random.nextInt(emojis.length)];
      elements.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: random.nextInt(5) + 3),
            builder: (context, double value, child) {
              // Starting small and growing + slight rotation
              final scale = value * 1.2;
              final rotation = sin(value * 3 * pi) * 0.3;
              
              return Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: size,
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
    
    return elements;
  }

  // Method to load premium status
  Future<void> _loadPremiumStatus() async {
    try {
      // This is a placeholder - in a real app, this would get the status from a service
      // For demo purposes, we'll hardcode it to false to show free finale experiences
      _isPremiumUser = false;
      
      // In a real app, you'd use a service like this:
      // final purchaseService = PurchaseService();
      // _isPremiumUser = purchaseService.isPremium;
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    }
  }
  
  // Filter end screens based on premium status
  List<Map<String, dynamic>> _getAvailableEndScreens() {
    if (_isPremiumUser) {
      return _endScreens; // All screens available
    } else {
      // Only non-premium screens
      return _endScreens.where((screen) => screen['isPremium'] == false).toList();
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