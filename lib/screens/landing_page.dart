import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_package.dart';
import '../services/purchase_service.dart';
import '../utils/app_assets.dart';
import 'game_mode_selection_page.dart';
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
  final TextEditingController _playerController = TextEditingController();
  List<String> players = [];
  bool _quickDrinkMode = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _playerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final String playerName = _playerController.text.trim();
    if (playerName.isNotEmpty && !players.contains(playerName)) {
      setState(() {
        players.add(playerName);
        _playerController.clear();
      });
    } else if (playerName.isNotEmpty && players.contains(playerName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Player "$playerName" already added!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removePlayer(String player) {
    setState(() {
      players.remove(player);
    });
  }

  void _startGame() {
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Please add at least 2 players to start!'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      
      _shakeController.forward(from: 0.0);
      
      HapticFeedback.heavyImpact();

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
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
             gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF7B1FA2), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6, 1.0],
              ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'D',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -2,
                      height: 0.8, 
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: _buildPlayerInput(),
                  ),
                  const SizedBox(height: 20),
                  _buildPlayerList(),
                  const SizedBox(height: 30),
                  _buildQuickDrinkToggle(),
                  const SizedBox(height: 40),
                  _buildStartButton(),
                  const SizedBox(height: 20),
                  _buildShareButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInput() {
    return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
       ),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
              'Add Players (min 2)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter player name...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7B1FA2),
                    padding: const EdgeInsets.all(12), 
                    shape: const CircleBorder(),
                    elevation: 2,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
        ],
       ),
    );
  }

  Widget _buildPlayerList() {
    if (players.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: players
          .map((player) => Chip(
                label: Text(player),
                labelStyle: const TextStyle(color: Color(0xFF7B1FA2)),
                backgroundColor: Colors.white.withOpacity(0.9),
                deleteIconColor: const Color(0xFF7B1FA2).withOpacity(0.7),
                onDeleted: () => _removePlayer(player),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildQuickDrinkToggle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quick Drink Mode',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Switch(
              value: _quickDrinkMode,
              onChanged: (value) {
                setState(() {
                  _quickDrinkMode = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.purple.shade300,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Random shot alerts during the game!',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF7B1FA2),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      onPressed: _startGame,
      child: const Text('LET\'S PLAY!'),
    );
  }

  Widget _buildShareButton() {
     return TextButton.icon(
        icon: const Icon(Icons.share, size: 18, color: Colors.white70),
        label: const Text(
          'Share with friends',
           style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        style: TextButton.styleFrom(padding: const EdgeInsets.all(10)),
        onPressed: _shareApp,
      );
  }
} 