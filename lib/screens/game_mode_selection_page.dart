import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
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
        // Enhanced AlertDialog for Premium
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B1FA2), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 28),
                SizedBox(width: 12),
                Text('DrunkHub Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unlock 14+ premium drinking games and challenges!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _buildPremiumFeature(Icons.games_rounded, '14+ Premium Game Modes'),
              _buildPremiumFeature(Icons.local_drink_rounded, 'Exclusive Drinking Challenges'),
              _buildPremiumFeature(Icons.celebration_rounded, 'Special Occasion Games'),
              _buildPremiumFeature(Icons.auto_awesome_rounded, 'Regular Content Updates'),
              const SizedBox(height: 20),
              // Weekly Subscription Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _showLoadingDialog();
                  try {
                    await _purchaseService.purchaseWeekly();
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    if (mounted) Navigator.of(context).pop();
                    _showErrorDialog('Payment Required',
                        'This is a demo app. In a real app, this would connect to the payment system.');
                  }
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Subscription',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_purchaseService.formattedWeeklyPrice}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Includes 3-Day Free Trial',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Lifetime Access Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _showLoadingDialog();
                  try {
                    await _purchaseService.purchaseLifetime();
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    if (mounted) Navigator.of(context).pop();
                    _showErrorDialog('Payment Required',
                        'This is a demo app. In a real app, this would connect to the payment system.');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.all_inclusive_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Lifetime Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(
                      '${_purchaseService.formattedLifetimePrice}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Redeem Code Button
              TextButton.icon(
                icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                label: const Text('Redeem Access Code'),
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showRedemptionCodeDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  // Updated helper widget for premium features
  Widget _buildPremiumFeature(IconData icon, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A237E), size: 20),
          const SizedBox(width: 10),
          Expanded( // Allow text to wrap
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRedemptionCodeDialog() {
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.purple, size: 30),
                  SizedBox(width: 10),
                  Text('Redeem Access Code',
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
                    'Enter your one-time access code to unlock 1 year of premium features!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Access Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key),
                      hintText: 'Example: DRUNK-HUB-2025',
                    ),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This code can be redeemed only once.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (codeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid code'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    setState(() {
                      isLoading = true;
                    });
                    
                    // Simulate API call to validate code
                    await Future.delayed(const Duration(seconds: 1));
                    
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                      
                      // For demo purposes, accept any code
                      Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This is a demo. In a real app, this would validate your code.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Redeem',
                    style: TextStyle(
                          color: Colors.white,
                      fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ],
            );
          }
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
          gradient: isSelected 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E),  // Deeper blue
                  Color(0xFF7B1FA2),  // Richer purple
                ],
              )
            : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? const Color(0xFF1A237E).withOpacity(0.5)  // More prominent shadow
                : Colors.black.withAlpha(13),
              blurRadius: isSelected ? 15 : 10,  // Larger blur for selected
              spreadRadius: isSelected ? 3 : 0,  // More spread for selected
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),  // Larger padding
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),  // Larger radius
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),  // More visible shadow
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Text(
                      mode.icon,
                      style: TextStyle(fontSize: isSelected ? 28 : 24),  // Larger for selected
                    ),
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
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 18,  // Larger for selected
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (mode.isPremium) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.star,
                                size: isSelected ? 22 : 18,  // Larger for selected
                                color: isLocked ? Colors.grey : Colors.amber,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),  // More space
                        Text(
                          mode.description,
                          style: TextStyle(
                            fontSize: isSelected ? 15 : 14,  // Larger for selected
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,  // Bolder for selected
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(6),  // Larger
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF7B1FA2),  // Use purple for better visibility
                        size: 28,  // Larger
                      ),
                    ),
                ],
              ),
            ),
            if (isLocked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black45,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Selection indicator overlay
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  transform: Matrix4.translationValues(10, -10, 0),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF7B1FA2),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    if (selectedModes.isEmpty) {
      // If no modes are selected, show a dialog suggesting to select at least one
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Game Modes Selected'),
            content: const Text('Would you like to use the "Getting Started" game mode or select your own?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add the "Getting Started" game mode
                  final startingMode = gameModes.firstWhere(
                    (mode) => mode.id == 'getting_started',
                    orElse: () => gameModes.first,
                  );
                  
                  setState(() {
                    selectedModes.add(startingMode);
                  });
                  
                  // Now start the game with this mode
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
                },
                child: const Text('Use Getting Started', style: TextStyle(color: Color(0xFF1A237E))),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Select My Own', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      );
    } else {
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

  // Redemption code dialog
  void _showAccessCodeDialog() {
    _showRedemptionCodeDialog();
  }
} 