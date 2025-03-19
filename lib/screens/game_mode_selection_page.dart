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
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('DrunkHub Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Features:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPremiumFeature('9 Premium Game Bundles'),
                      _buildPremiumFeature('7 Epic Finale Experiences'),
                      _buildPremiumFeature('No Ads or Restrictions'),
                      _buildPremiumFeature('Regular New Content'),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Weekly subscription
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Show loading indicator
                      _showLoadingDialog();
                      try {
                        await _purchaseService.purchaseWeekly();
                        if (mounted) Navigator.of(context).pop(); // Dismiss loading
                      } catch (e) {
                        if (mounted) Navigator.of(context).pop(); // Dismiss loading
                        _showErrorDialog('Payment Required', 
                          'This is a demo app. In a real app, this would connect to the payment system.');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Subscription',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${_purchaseService.currencySymbol}${_purchaseService.weeklyPrice}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '3-DAY FREE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Lifetime access
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B1FA2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lifetime Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_purchaseService.currencySymbol}${_purchaseService.lifetimePrice}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Redemption code
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF1A237E)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showRedemptionCodeDialog();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.card_giftcard, size: 18, color: Color(0xFF1A237E)),
                        const SizedBox(width: 8),
                        const Text(
                          'Redeem Access Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Maybe Later'),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // Helper widget for premium features
  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF1A237E), size: 16),
          const SizedBox(width: 6),
          Text(
            feature,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
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
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.5),
                  const Color(0xFF7B1FA2).withOpacity(0.5),
                ],
              )
            : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? const Color(0xFF1A237E).withOpacity(0.2)
                : Colors.black.withAlpha(13),
              blurRadius: 10,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 2),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ] : null,
                    ),
                    child: Text(
                      mode.icon,
                      style: const TextStyle(fontSize: 24),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
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
                            color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1A237E),
                        size: 24,
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

  // Redemption code dialog
  void _showAccessCodeDialog() {
    _showRedemptionCodeDialog();
  }
} 