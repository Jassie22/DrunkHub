import 'package:flutter/material.dart';
import 'game_mode_selection_page.dart';
import '../utils/app_assets.dart';
import 'package:share_plus/share_plus.dart';

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

  void _addPlayer(String? text) {
    if (text?.trim().isNotEmpty == true) {
      setState(() {
        players.add(text!.trim());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background video or image
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A237E),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // Logo and content
          SafeArea(
            child: Column(
              children: [
                // App logo and title
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      AppAssets.getAppIconSvg(width: 80, height: 80),
                      const SizedBox(height: 10),
                      const Text(
                        'DRUNKHUB',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Social Drinking Game',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Player list and add player functionality
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Player counter and help text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                children: [
                                  const TextSpan(text: 'Players: '),
                                  TextSpan(
                                    text: '${players.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                // Show help dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    title: Text('How to Play'),
                                    content: Text('Add players to the game, select game modes, and enjoy responsibly! The app will randomly select prompts based on the modes you choose.'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        
                        // Player list
                        Expanded(
                          child: players.isEmpty
                              ? Center(
                                  child: Text(
                                    'Add players to start',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withAlpha(150),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: players.length,
                                  itemBuilder: (context, index) {
                                    final player = players[index];
                                    return Card(
                                      color: Colors.white.withOpacity(0.1),
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          player,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              players.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        
                        // Add player field
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter player name',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: _addPlayer,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _addPlayer(_controller.text);
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Drink mode toggle
                        SwitchListTile(
                          title: const Text(
                            'Quick Drink Mode',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Drink alerts during gameplay',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          value: _quickDrinkMode,
                          activeColor: Colors.redAccent,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _quickDrinkMode = value;
                            });
                          },
                        ),
                        
                        // Let's Play button - centered
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            child: ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
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
              ],
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
      bottomNavigationBar: Container(
        color: const Color(0xFF1A237E),
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20), // Even thinner vertical padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to space between for share button
          children: [
            // Copyright text
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Row(
                        children: [
                          AppAssets.getAppIconSvg(
                            width: 18,
                            height: 18,
                            color: const Color(0xFF1A237E),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Legal Information',
                            style: TextStyle(
                              fontSize: 16,
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
                            Text(
                              'Copyright © 2025 True Node Limited',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'All rights reserved. This application and its content are licensed for personal use only.',
                            ),
                            SizedBox(height: 12),
                            Text(
                              'DrunkHub is an entertainment app designed for adults of legal drinking age. Please drink responsibly.',
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                '© 2025 True Node',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8, // Even smaller text
                ),
              ),
            ),
            
            // Share button
            TextButton.icon(
              onPressed: () {
                // Share the app with friends
                Share.share(
                  'Check out DrunkHub - the ultimate social drinking game app! https://truenode.com/drunkhub',
                  subject: 'DrunkHub - Social Drinking Game',
                );
              },
              icon: const Icon(Icons.share, size: 14, color: Colors.white70),
              label: const Text(
                'Share with friends',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8, // Small text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 