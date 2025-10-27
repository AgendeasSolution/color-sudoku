import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to manage rewarded ads
class RewardedAdService {
  static RewardedAdService? _instance;
  static RewardedAdService get instance => _instance ??= RewardedAdService._();
  
  RewardedAdService._();

  RewardedAd? _rewardedAd;
  bool _isAdReady = false;
  bool _isLoading = false;
  bool _rewardEarned = false;
  VoidCallback? _onAdDismissedCallback;
  VoidCallback? _onRewardEarnedCallback;
  Completer<void>? _loadingCompleter;

  /// Test ad unit ID for development
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  /// Production ad unit ID from AdMob console
  static const String _productionAdUnitId = 'ca-app-pub-3772142815301617/2105456290';

  /// Current ad unit ID (using production for live app)
  /// Change to _testAdUnitId for development/testing
  static const String _adUnitId = _productionAdUnitId;

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;
  
  /// Check if reward was earned in the last ad
  bool get wasRewardEarned => _rewardEarned;

  /// Load rewarded ad
  Future<void> loadAd() async {
    if (_isLoading) {
      print('Ad is already loading, waiting for completion...');
      // Wait for the existing loading completer
      if (_loadingCompleter != null) {
        try {
          await _loadingCompleter!.future.timeout(
            Duration(seconds: 5),
            onTimeout: () {
              print('Timeout waiting for ad to load, resetting state...');
              _isLoading = false;
              _loadingCompleter = null;
            },
          );
        } catch (e) {
          print('Error waiting for ad load: $e');
          _isLoading = false;
          _loadingCompleter = null;
        }
      }
      
      // If ad is ready now, return
      if (_isAdReady) {
        return;
      }
    }
    
    if (_isAdReady) {
      print('Ad is already ready');
      return;
    }

    _isLoading = true;
    _isAdReady = false;
    _loadingCompleter = Completer<void>();
    print('Loading rewarded ad with ID: $_adUnitId');

    try {
      // Add a small delay to ensure AdMob is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print('Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isAdReady = true;
            _isLoading = false;
            
            // Set up ad callbacks
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('Rewarded ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('Rewarded ad dismissed - Reward earned: $_rewardEarned');
                // Call the callback when ad is dismissed
                _onAdDismissedCallback?.call();
                _onAdDismissedCallback = null; // Clear callback
                _disposeAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Rewarded ad failed to show: $error');
                _disposeAd();
              },
            );
            
            // Complete the loading completer
            _loadingCompleter?.complete();
            _loadingCompleter = null;
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: $error');
            _isLoading = false;
            _isAdReady = false;
            _rewardedAd = null;
            
            // Complete the loading completer with error
            _loadingCompleter?.complete();
            _loadingCompleter = null;
          },
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
      _isLoading = false;
      _isAdReady = false;
      _rewardedAd = null;
      
      // Complete the loading completer with error
      _loadingCompleter?.complete();
      _loadingCompleter = null;
    }
  }

  /// Show rewarded ad if ready
  Future<bool> showAd({
    VoidCallback? onAdDismissed,
    VoidCallback? onRewardEarned,
  }) async {
    // Try up to 3 times to load and show ad
    for (int attempt = 1; attempt <= 3; attempt++) {
      print('Attempt $attempt to show rewarded ad');
      print('Current state: isAdReady=$_isAdReady, isLoading=$_isLoading');
      
      if (!_isAdReady || _rewardedAd == null) {
        print('Rewarded ad not ready, loading new ad...');
        await loadAd();
        print('After loadAd: isAdReady=$_isAdReady, isLoading=$_isLoading');
        
        // Wait a bit more for the ad to be fully ready
        if (_isAdReady && _rewardedAd != null) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      // Check if ad is ready after loading
      if (!_isAdReady || _rewardedAd == null) {
        print('Rewarded ad still not ready after loading attempt $attempt');
        if (attempt < 3) {
          // Wait before retry
          await Future.delayed(const Duration(milliseconds: 1000));
          continue;
        } else {
          print('All attempts failed to load rewarded ad');
          return false;
        }
      }

      try {
        // Reset reward status
        _rewardEarned = false;
        
        // Store the callbacks
        _onAdDismissedCallback = onAdDismissed;
        _onRewardEarnedCallback = onRewardEarned;
        
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            print('User earned reward: ${reward.amount} ${reward.type}');
            _rewardEarned = true;
            // Call the reward callback when user earns reward
            _onRewardEarnedCallback?.call();
          },
        );
        print('Rewarded ad shown successfully on attempt $attempt');
        return true;
      } catch (e) {
        print('Error showing rewarded ad on attempt $attempt: $e');
        _disposeAd();
        
        if (attempt < 3) {
          // Wait before retry
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }
    }
    
    print('All attempts to show rewarded ad failed');
    return false;
  }

  /// Show rewarded ad with 100% probability (always show for rewards)
  /// Returns true if ad was shown, false if not shown (due to loading errors)
  Future<bool> showAdAlways({
    VoidCallback? onAdDismissed,
    VoidCallback? onRewardEarned,
  }) async {
    return await showAd(
      onAdDismissed: onAdDismissed,
      onRewardEarned: onRewardEarned,
    );
  }

  /// Preload ad for better user experience
  Future<void> preloadAd() async {
    if (!_isAdReady && !_isLoading) {
      print('Preloading rewarded ad...');
      await loadAd();
      
      // After loading, wait a bit more to ensure it's fully ready
      if (_isAdReady) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('Rewarded ad preloaded and ready');
      }
    }
  }

  /// Dispose current ad
  void _disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
    
    // Immediately start loading the next ad for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isLoading && !_isAdReady) {
        print('Auto-preloading next rewarded ad...');
        preloadAd();
      }
    });
  }

  /// Dispose service
  void dispose() {
    _disposeAd();
  }
}
