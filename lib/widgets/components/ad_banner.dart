import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
    //   margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
      ),
      child: const Center(
        child: Text(
          'Ad Space',
          style: TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
