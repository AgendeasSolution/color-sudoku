import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor internet connectivity status
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _hasInternetConnection = true;
  bool get hasInternetConnection => _hasInternetConnection;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity status
    await _checkConnectivity();
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _checkConnectivity();
      },
    );
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      // Check if any connection type is available
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      
      if (_hasInternetConnection != hasConnection) {
        _hasInternetConnection = hasConnection;
        notifyListeners();
      }
    } catch (e) {
      // If check fails, assume no connection
      if (_hasInternetConnection) {
        _hasInternetConnection = false;
        notifyListeners();
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}


