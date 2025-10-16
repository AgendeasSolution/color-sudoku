import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A reusable ad banner component that displays Google AdMob banner ads
class AdBanner extends StatefulWidget {
  final double? height;
  final String? adUnitId;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;

  const AdBanner({
    super.key,
    this.height,
    this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _hasAdError = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  // Test ad unit ID for development
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // Production ad unit ID from the AdMob console
  static const String _productionAdUnitId =
      'ca-app-pub-3772142815301617/4282023494';

  @override
  void initState() {
    super.initState();
    _initializeAndLoadAd();
    
    // Set up periodic refresh to keep ads loading
    _setupPeriodicRefresh();
  }

  void _setupPeriodicRefresh() {
    // Refresh ad every 30 seconds to keep it fresh
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isAdLoaded) {
        print('Banner ad: Periodic refresh triggered');
        _refreshAd();
      }
    });
  }

  void _refreshAd() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
    
    setState(() {
      _isAdLoaded = false;
      _isAdLoading = false;
      _hasAdError = false;
      _retryCount = 0; // Reset retry count for fresh attempt
    });
    
    _loadBannerAd();
  }

  void _initializeAndLoadAd() async {
    try {
      // MobileAds is already initialized in main.dart
      _loadBannerAd();
    } catch (e) {
      print('Failed to load banner ad: $e');
      // If plugin is not available, show placeholder
      if (mounted) {
        setState(() {
          _isAdLoading = false;
          _hasAdError = false;
          _isAdLoaded = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    if (_isAdLoading || _isAdLoaded || !mounted) return;

    setState(() {
      _isAdLoading = true;
      _hasAdError = false;
    });

    try {
      _bannerAd = BannerAd(
        adUnitId: widget.adUnitId ?? _productionAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              print('Banner ad: Successfully loaded');
              setState(() {
                _isAdLoaded = true;
                _isAdLoading = false;
                _hasAdError = false;
                _retryCount = 0; // Reset retry count on successful load
              });
              widget.onAdLoaded?.call();
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (mounted) {
              print('Banner ad failed to load: $error');
              print('Error code: ${error.code}, Message: ${error.message}');
              print('Retry count: $_retryCount');

              // Handle different error types
              if (error.code == 3) {
                print('No fill error - no ads available for this ad unit (skipping retry)');
                // Don't retry for "No Fill" - there are simply no ads available
              } else if (error.code == 0) {
                print('Internal error - check ad unit ID and configuration');
              } else if (error.code == 1) {
                print('Invalid request - check ad unit ID format');
              }

              setState(() {
                _isAdLoaded = false;
                _isAdLoading = false;
                _hasAdError = true;
              });
              ad.dispose();
              
              // Only retry for errors other than "No Fill"
              if (error.code != 3) {
                _scheduleRetry();
              }
              
              widget.onAdFailedToLoad?.call();
            }
          },
        ),
      );

      _bannerAd!.load();
    } catch (e) {
      print('Error creating banner ad: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
          _isAdLoading = false;
          _hasAdError = true;
        });
        widget.onAdFailedToLoad?.call();
      }
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    
    // Increase retry count
    _retryCount++;
    
    // Don't retry more than 5 times
    if (_retryCount > 5) {
      print('Banner ad: Max retry attempts reached, giving up');
      return;
    }
    
    // Exponential backoff: 2s, 4s, 8s, 16s, 32s
    final retryDelay = Duration(seconds: 2 * _retryCount);
    print('Banner ad: Scheduling retry #$_retryCount in ${retryDelay.inSeconds}s');
    
    _retryTimer = Timer(retryDelay, () {
      if (mounted && !_isAdLoaded) {
        print('Banner ad: Attempting retry #$_retryCount');
        _retryLoadAd();
      }
    });
  }

  void _retryLoadAd() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
    
    setState(() {
      _isAdLoading = false;
      _hasAdError = false;
    });
    
    _loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height ?? 60.0, // Increased height for better ad display
      margin: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 4.0,
        bottom: 16.0, // Added extra bottom margin for better spacing
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0), // Slight rounded corners
      ),
      child: _buildAdContent(),
    );
  }

  Widget _buildAdContent() {
    if (_isAdLoading) {
      return const SizedBox.shrink(); // Hide loading indicator completely
    }

    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        width: double.infinity,
        height: widget.height ?? 60.0,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0), // Inner padding
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    if (_hasAdError) {
      return const SizedBox.shrink(); // Hide error state completely
    }

    // Show placeholder when plugin is not available or ad is not loaded
    return const SizedBox.shrink(); // Hide placeholder completely
  }
}
