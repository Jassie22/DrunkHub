import 'package:flutter/material.dart';
import 'game_mode_selection_page.dart';
import '../utils/app_assets.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/logo_painter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  final List<String> players = [];
  final TextEditingController _controller = TextEditingController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _hasAcknowledgedWarning = false;
  bool _showRedOverlay = false;
  bool _quickDrinkMode = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    // Show warning dialog after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasAcknowledgedWarning) {
        _showWarningDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        players.add(_controller.text.trim());
        _controller.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      players.removeAt(index);
    });
  }

  void _startGame() {
    if (players.length < 2) {
      setState(() {
        _showRedOverlay = true;
      });
      
      // Shake animation for warning message
      _shakeController.forward().then((_) {
        _shakeController.reverse().then((_) {
          _shakeController.forward().then((_) {
            _shakeController.reverse();
          });
        });
      });
      
      // Reset the red overlay after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showRedOverlay = false;
          });
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameModeSelectionPage(
            players: players,
            quickDrinkMode: _quickDrinkMode,
          ),
        ),
      );
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, 
                   color: Colors.amber[700], 
                   size: 30),
              const SizedBox(width: 10),
              const Text('Drink Responsibly',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please acknowledge the following:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('• Never drink and drive'),
                Text('• Know your limits'),
                Text('• Stay hydrated'),
                Text('• Have a designated driver'),
                Text('• Keep your drinks in sight'),
                SizedBox(height: 10),
                Text('By clicking "I Understand", you confirm that you will follow these guidelines and drink responsibly.',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                setState(() {
                  _hasAcknowledgedWarning = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('I Understand',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  void _shareApp() async {
    try {
      // Create a logo image with watermark
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Set the size of the image
      const size = Size(600, 600);
      
      // Draw a gradient background similar to the app
      final Paint bgPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E), // Deep Blue
            Color(0xFF7B1FA2), // Purple
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
      
      // Create a text style and painter
      const text = 'Try DrunkHub!';
      const subText = 'The ultimate drinking game app';
      
      final textPainter = TextPainter(
        text: const TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      final subTextPainter = TextPainter(
        text: const TextSpan(
          text: subText,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 30,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      // Layout and paint the text in the center
      textPainter.layout(maxWidth: size.width);
      subTextPainter.layout(maxWidth: size.width);
      
      textPainter.paint(
        canvas, 
        Offset((size.width - textPainter.width) / 2, size.height / 2 - 70)
      );
      
      subTextPainter.paint(
        canvas, 
        Offset((size.width - subTextPainter.width) / 2, size.height / 2)
      );
      
      // Draw the logo watermark in the bottom right corner
      final logoPainter = LogoPainter(
        baseColor: Colors.white,
        isWatermark: true,
      );
      
      final logoSize = Size(120, 120);
      final logoOffset = Offset(size.width - 130, size.height - 130);
      
      canvas.save();
      canvas.translate(logoOffset.dx, logoOffset.dy);
      logoPainter.paint(canvas, logoSize);
      canvas.restore();
      
      // Convert to an image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      
      // Share the image
      await Share.shareXFiles(
        [
          XFile.fromData(
            buffer,
            name: 'drunkhub_share.png',
            mimeType: 'image/png',
          ),
        ],
        text: 'Check out DrunkHub - The ultimate drinking game app! Download now: https://drunkhub.app',
      );
    } catch (e) {
      debugPrint('Error sharing app: $e');
      // Fallback to simple text sharing
      await Share.share('Check out DrunkHub - The ultimate drinking game app! Download now: https://drunkhub.app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with original gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // Deep Blue
                  Color(0xFF7B1FA2), // Purple
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AppAssets.getAppIconSvg(
                      width: 120,
                      height: 120,
                    ),
                    const Text(
                      'DRUNKHUB',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A237E),
                            Color(0xFF7B1FA2),
                          ],
                          stops: [0.0, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    hintText: 'Enter player name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  onSubmitted: (_) => _addPlayer(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: _addPlayer,
                                color: Colors.white,
                                iconSize: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: players.asMap().entries.map((entry) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => _removePlayer(entry.key),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sudden Drink Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Switch(
                                  value: _quickDrinkMode,
                                  onChanged: (value) {
                                    setState(() {
                                      _quickDrinkMode = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF7B1FA2),
                                  activeTrackColor: Colors.white.withAlpha(100),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withAlpha(50),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Random shot alerts during the game',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(180),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    // Share app button (more prominent)
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      child: ElevatedButton.icon(
                        onPressed: _shareApp,
                        icon: const Icon(Icons.share, size: 24, color: Color(0xFF1A237E)),
                        label: const Text(
                          'Share with Friends',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 30),
                        child: ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Let's Play!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Red overlay with warning message
          if (_showRedOverlay)
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Container(
                color: Colors.red.withAlpha(77),
                child: const Center(
                  child: Text(
                    'ADD AT LEAST\n2 PLAYERS!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.red,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 