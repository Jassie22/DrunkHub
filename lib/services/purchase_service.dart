import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

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
  String _currencySymbol = '\$';
  String _weeklyPrice = '2.99';
  String _lifetimePrice = '9.99';
  
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get currencySymbol => _currencySymbol;
  String get weeklyPrice => _weeklyPrice;
  String get lifetimePrice => _lifetimePrice;
  
  Future<void> initialize() async {
    // Load premium status from shared preferences
    await _loadPremiumStatus();
    _setLocalizedPrices();
    debugPrint('PurchaseService initialized: isPremium = $_isPremium, currency = $_currencySymbol');
  }
  
  void _setLocalizedPrices() {
    try {
      // This is a simplified demo version using static prices
      // In a real app, you would use the in_app_purchase package
      // to query product details with localized pricing
      
      // Simulate getting the locale from the device
      String deviceLocale = Platform.localeName.split('_')[1];
      
      // Set currency symbol and prices based on locale
      switch (deviceLocale) {
        case 'US':
          _currencySymbol = '\$';
          _weeklyPrice = '2.99';
          _lifetimePrice = '9.99';
          break;
        case 'GB':
          _currencySymbol = '£';
          _weeklyPrice = '2.49';
          _lifetimePrice = '8.99';
          break;
        case 'EU':
        case 'DE':
        case 'FR':
        case 'IT':
        case 'ES':
          _currencySymbol = '€';
          _weeklyPrice = '2.99';
          _lifetimePrice = '9.99';
          break;
        case 'JP':
          _currencySymbol = '¥';
          _weeklyPrice = '350';
          _lifetimePrice = '1,200';
          break;
        case 'KR':
          _currencySymbol = '₩';
          _weeklyPrice = '3,900';
          _lifetimePrice = '12,900';
          break;
        case 'IN':
          _currencySymbol = '₹';
          _weeklyPrice = '249';
          _lifetimePrice = '799';
          break;
        case 'BR':
          // Brazilian Real
          _currencySymbol = 'R\$';
          _weeklyPrice = '11.99';
          _lifetimePrice = '39.99';
          break;
        case 'RU':
          // Russian Ruble
          _currencySymbol = 'RUB';
          _weeklyPrice = '229';
          _lifetimePrice = '799';
          break;
        case 'CN':
          // Chinese Yuan
          _currencySymbol = 'CNY';
          _weeklyPrice = '19.99';
          _lifetimePrice = '69.99';
          break;
        case 'AU':
          // Australian Dollar
          _currencySymbol = 'A\$';
          _weeklyPrice = '4.49';
          _lifetimePrice = '14.99';
          break;
        case 'CA':
          // Canadian Dollar
          _currencySymbol = 'C\$';
          _weeklyPrice = '3.99';
          _lifetimePrice = '12.99';
          break;
        default:
          _currencySymbol = '\$';
          _weeklyPrice = '2.99';
          _lifetimePrice = '9.99';
      }
    } catch (e) {
      debugPrint('Error setting localized prices: $e, using defaults');
      _currencySymbol = '\$';
      _weeklyPrice = '2.99';
      _lifetimePrice = '9.99';
    }
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