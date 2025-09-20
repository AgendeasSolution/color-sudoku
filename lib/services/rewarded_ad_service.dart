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

  /// Test ad unit ID for development
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  /// Production ad unit ID from AdMob console
  static const String _productionAdUnitId = 'ca-app-pub-3772142815301617/2105456290';

  /// Current ad unit ID (using production for live app)
  /// Change to _testAdUnitId for development/testing
  static const String _adUnitId = _testAdUnitId;

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;
  
  /// Check if reward was earned in the last ad
  bool get wasRewardEarned => _rewardEarned;

  /// Load rewarded ad
  Future<void> loadAd() async {
    if (_isLoading || _isAdReady) return;

    _isLoading = true;
    print('Loading rewarded ad...');

    try {
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
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: $error');
            _isLoading = false;
            _isAdReady = false;
          },
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
      _isLoading = false;
      _isAdReady = false;
    }
  }

  /// Show rewarded ad if ready
  Future<bool> showAd({
    VoidCallback? onAdDismissed,
    VoidCallback? onRewardEarned,
  }) async {
    if (!_isAdReady || _rewardedAd == null) {
      print('Rewarded ad not ready, loading new ad...');
      await loadAd();
      return false;
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
      return true;
    } catch (e) {
      print('Error showing rewarded ad: $e');
      _disposeAd();
      return false;
    }
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
      await loadAd();
    }
  }

  /// Dispose current ad
  void _disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
  }

  /// Dispose service
  void dispose() {
    _disposeAd();
  }
}
