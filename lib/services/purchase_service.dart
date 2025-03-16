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
  }
  
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool('isPremium') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    }
  }
  
  Future<void> _savePremiumStatus(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', status);
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
  
  // Simulate starting a free trial
  Future<void> startFreeTrial() async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      await _savePremiumStatus(true);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Simulate subscribing weekly
  Future<void> subscribeWeekly() async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      await _savePremiumStatus(true);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Simulate purchasing lifetime access
  Future<void> purchaseLifetime() async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      await _savePremiumStatus(true);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Simulate restoring purchases
  Future<void> restorePurchases() async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      // For testing, we'll just set premium to true
      // In a real app, this would check with the store
      await _savePremiumStatus(true);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
} 