import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/game_package.dart';
import '../services/purchase_service.dart';
import 'game_screen.dart';

class PackageSelectionPage extends StatefulWidget {
  final List<String> players;

  const PackageSelectionPage({
    super.key,
    required this.players,
  });

  @override
  State<PackageSelectionPage> createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  bool isPremiumUser = false;
  final Set<GamePackage> selectedPackages = {};
  final PurchaseService _purchaseService = PurchaseService();

  @override
  void initState() {
    super.initState();
    _initializePurchases();
  }

  Future<void> _initializePurchases() async {
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

  void _togglePackageSelection(GamePackage package) {
    if (package.isPremium && !isPremiumUser) {
      _showPurchaseOptions();
      return;
    }

    setState(() {
      if (selectedPackages.contains(package)) {
        selectedPackages.remove(package);
      } else {
        selectedPackages.add(package);
      }
    });
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 30),
              SizedBox(width: 10),
              Text('Unlock Premium',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Get access to all premium game packages:'),
              const SizedBox(height: 10),
              ...gamePackages
                  .where((p) => p.isPremium)
                  .map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(p.icon),
                            const SizedBox(width: 8),
                            Text(p.name),
                          ],
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 15),
              const Text(
                '✓ All premium packages\n✓ No ads\n✓ Future updates included',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
          ],
          actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
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
                    await _purchaseService.togglePremiumForTesting();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isPremiumUser 
                          ? 'Premium status removed for testing' 
                          : 'Premium status granted for testing'),
                        backgroundColor: isPremiumUser ? Colors.red : Colors.green,
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

  Widget _buildPackageCard(GamePackage package) {
    final bool isSelected = selectedPackages.contains(package);
    final bool isLocked = package.isPremium && !isPremiumUser;
    final bool isAdultContent = package.id == 'flirty_fun' || package.id == 'heat_it_up' || package.id == 'no_limits';

    return GestureDetector(
      onTap: () {
        // Remove the adult content warning and directly toggle selection
        _togglePackageSelection(package);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                    package.icon,
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
                              package.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (package.isPremium) ...[
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
                          package.description,
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
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<GamePackage>> categorizedPackages = {};
    
    for (var package in gamePackages) {
      if (!categorizedPackages.containsKey(package.category)) {
        categorizedPackages[package.category] = [];
      }
      categorizedPackages[package.category]!.add(package);
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
                      'Choose Game Packages',
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
                    if (!categorizedPackages.containsKey(category)) {
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
                        ...categorizedPackages[category]!.map(_buildPackageCard),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (selectedPackages.isNotEmpty)
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            players: widget.players,
                            selectedPackages: selectedPackages.toList(),
                          ),
                        ),
                      );
                    },
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
    );
  }
} 