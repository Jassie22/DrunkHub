import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is a simplified version of the purchase service for testing
// In a production app, you would use the in_app_purchase package
class PurchaseService extends ChangeNotifier {
  static final PurchaseService _instance = PurchaseService._internal();
  
  // Product IDs - these should match what's configured in Google Play Console
  static const String freeTrialProductId = 'drunkhub_free_trial';
  static const String weeklySubscriptionId = 'drunkhub_weekly_subscription';
  static const String lifetimeAccessId = 'drunkhub_lifetime_access';
  
  // Singleton factory constructor
  factory PurchaseService() {
    return _instance;
  }
  
  PurchaseService._internal();
  
  bool _isPremium = false;
  bool _isLoading = false;
  
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  
  Future<void> initialize() async {
    // Load premium status from shared preferences
    await _loadPremiumStatus();
    debugPrint('PurchaseService initialized: isPremium = $_isPremium');
  }
  
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool('isPremium') ?? false;
      debugPrint('Loaded premium status: $_isPremium');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    }
  }
  
  Future<void> _savePremiumStatus(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', status);
      debugPrint('Saved premium status: $status');
      _isPremium = status;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving premium status: $e');
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Purchase methods that simulate a payment flow but don't automatically grant access
  
  // Start free trial
  Future<void> startFreeTrial() async {
    _setLoading(true);
    
    try {
      // Simulate a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would connect to the payment system
      // For now, we'll throw an exception to indicate payment is required
      _setLoading(false);
      throw Exception('This is a demo app. In a real app, this would connect to the payment system.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Subscribe weekly
  Future<void> subscribeWeekly() async {
    _setLoading(true);
    
    try {
      // Simulate a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would connect to the payment system
      // For now, we'll throw an exception to indicate payment is required
      _setLoading(false);
      throw Exception('This is a demo app. In a real app, this would connect to the payment system.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Purchase weekly subscription
  Future<void> purchaseWeekly() async {
    _setLoading(true);
    
    try {
      // Simulate a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would connect to the payment system
      // For now, we'll throw an exception to indicate payment is required
      _setLoading(false);
      throw Exception('This is a demo app. In a real app, this would connect to the payment system.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Purchase lifetime access
  Future<void> purchaseLifetime() async {
    _setLoading(true);
    
    try {
      // Simulate a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would connect to the payment system
      // For now, we'll throw an exception to indicate payment is required
      _setLoading(false);
      throw Exception('This is a demo app. In a real app, this would connect to the payment system.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Restore purchases
  Future<void> restorePurchases() async {
    _setLoading(true);
    
    try {
      // Simulate a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would connect to the payment system
      // For now, we'll throw an exception to indicate payment is required
      _setLoading(false);
      throw Exception('This is a demo app. In a real app, this would connect to the payment system.');
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // For testing purposes only - DO NOT USE IN PRODUCTION
  Future<void> togglePremiumForTesting() async {
    final newStatus = !_isPremium;
    debugPrint('Toggling premium status from $_isPremium to $newStatus');
    await _savePremiumStatus(newStatus);
    debugPrint('After toggle: isPremium = $_isPremium');
  }
  
  // Force set premium status (for testing)
  Future<void> setPremiumStatus(bool status) async {
    debugPrint('Forcing premium status to $status');
    await _savePremiumStatus(status);
  }
} 