import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/game_package.dart';
import '../services/purchase_service.dart';
import 'game_screen.dart';

class GameModeSelectionPage extends StatefulWidget {
  final List<String> players;
  final bool quickDrinkMode;

  const GameModeSelectionPage({
    super.key,
    required this.players,
    required this.quickDrinkMode,
  });

  @override
  State<GameModeSelectionPage> createState() => _GameModeSelectionPageState();
}

class _GameModeSelectionPageState extends State<GameModeSelectionPage> {
  bool isPremiumUser = false;
  final Set<GameMode> selectedModes = {};
  final PurchaseService _purchaseService = PurchaseService();

  @override
  void initState() {
    super.initState();
    _initializePurchases();
  }

  void _initializePurchases() async {
    await _purchaseService.initialize();
    setState(() {
      isPremiumUser = _purchaseService.isPremium;
    });

    // Listen for changes in premium status
    _purchaseService.addListener(() {
      setState(() {
        isPremiumUser = _purchaseService.isPremium;
      });
    });
  }

  void _showPurchaseOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 30),
              SizedBox(width: 10),
              Text('DrunkHub Premium',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unlock all premium drinking games and challenges!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Show loading indicator
                  _showLoadingDialog();
                  try {
                    await _purchaseService.purchaseLifetime();
                    if (mounted) Navigator.of(context).pop(); // Dismiss loading
                  } catch (e) {
                    if (mounted) Navigator.of(context).pop(); // Dismiss loading
                    _showErrorDialog('Payment Required', 
                      'This is a demo app. In a real app, this would connect to the payment system.');
                  }
                },
                child: const Text(
                  'Unlock Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Color(0xFF1A237E)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showAccessCodeDialog();
                },
                child: const Text(
                  'Enter Access Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (kDebugMode) // Only show in debug mode
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    
                    // Debug print before toggling
                    debugPrint('Before toggle: isPremium = ${_purchaseService.isPremium}');
                    
                    // Toggle premium status
                    await _purchaseService.togglePremiumForTesting();
                    
                    // Debug print after toggling
                    debugPrint('After toggle: isPremium = ${_purchaseService.isPremium}');
                    
                    // Force update the UI state
                    setState(() {
                      isPremiumUser = _purchaseService.isPremium;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isPremiumUser 
                          ? 'Premium status granted for testing' 
                          : 'Premium status removed for testing'),
                        backgroundColor: isPremiumUser ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: const Text(
                    'Toggle Premium (Testing)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe Later'),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing your purchase...'),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAccessCodeDialog() {
    final TextEditingController codeController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.vpn_key, color: Colors.amber, size: 24),
                  SizedBox(width: 10),
                  Text('Enter Access Code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your access code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isSubmitting 
                        ? null 
                        : () async {
                          if (codeController.text.trim() == '060125') {
                            setState(() {
                              isSubmitting = true;
                            });
                            
                            // Debug print before toggling
                            debugPrint('Before toggle: isPremium = ${_purchaseService.isPremium}');
                            
                            // Show success and grant premium
                            await _purchaseService.togglePremiumForTesting();
                            
                            // Debug print after toggling
                            debugPrint('After toggle: isPremium = ${_purchaseService.isPremium}');
                            
                            // Force update the UI state
                            this.setState(() {
                              isPremiumUser = _purchaseService.isPremium;
                            });
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Premium access ${isPremiumUser ? "granted" : "removed"}!'),
                                  backgroundColor: isPremiumUser ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          } else {
                            // Show error for invalid code
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid access code'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildGameModeCard(GameMode mode) {
    final bool isSelected = selectedModes.contains(mode);
    final bool isLocked = mode.isPremium && !isPremiumUser;

    return GestureDetector(
      onTap: () {
        // Only allow selection if the mode is not locked
        if (!isLocked) {
          setState(() {
            if (selectedModes.contains(mode)) {
              selectedModes.remove(mode);
            } else {
              selectedModes.add(mode);
            }
          });
        } else {
          // Show purchase options if the mode is locked
          _showPurchaseOptions();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E).withAlpha(26) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    mode.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mode.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (mode.isPremium) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: isLocked ? Colors.grey : Colors.amber,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1A237E),
                      size: 24,
                    ),
                ],
              ),
            ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withAlpha(128),
                                offset: const Offset(1, 1),
                              ),
                            ],
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

  void _startGame() {
    if (selectedModes.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            players: widget.players,
            selectedModes: selectedModes.toList(),
            quickDrinkMode: widget.quickDrinkMode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one game mode'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<GameMode>> categorizedModes = {};
    
    for (var mode in gameModes) {
      if (!categorizedModes.containsKey(mode.category)) {
        categorizedModes[mode.category] = [];
      }
      categorizedModes[mode.category]!.add(mode);
    }

    // Define the order of categories and their descriptions
    final Map<String, String> categoryInfo = {
      'Warm-Up (Free)': 'Simple, introductory games to get the party started.',
      'Classics': 'Traditional drinking games with a modern twist, including flirty options to spice things up.',
      'Challenges': 'Dares and challenges that push the party to the next level, from mild to wild.',
      'Special Occasions': 'Games designed for specific groups or events.',
    };

    // Define the order of categories
    final List<String> categoryOrder = categoryInfo.keys.toList();

    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Choose Game Modes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: categoryOrder.map((category) {
                    if (!categorizedModes.containsKey(category)) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            categoryInfo[category] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ...categorizedModes[category]!.map(_buildGameModeCard),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (selectedModes.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _startGame,
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      // Add a floating action button for quick premium toggle
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Toggle premium status
          final newStatus = !isPremiumUser;
          await _purchaseService.setPremiumStatus(newStatus);
          setState(() {
            isPremiumUser = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Premium access ${newStatus ? "FORCED ON" : "FORCED OFF"}'),
              backgroundColor: newStatus ? Colors.green : Colors.red,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: isPremiumUser ? Colors.red : Colors.green,
        child: Icon(isPremiumUser ? Icons.lock_open : Icons.vpn_key),
        tooltip: isPremiumUser ? 'Disable Premium' : 'Enable Premium',
      ),
    );
  }
} 