import 'package:flutter/material.dart';
import '../../../widgets/components/ad_banner.dart';

class BannerAdWidget extends StatelessWidget {
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;
  final VoidCallback? onAdClicked;

  const BannerAdWidget({
    super.key,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });

  @override
  Widget build(BuildContext context) {
    return AdBanner(
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }
}

