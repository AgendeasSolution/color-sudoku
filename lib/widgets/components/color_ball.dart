import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'ball.dart';

class ColorBall extends StatelessWidget {
  final Color color;
  final int count;
  final bool showShadow;

  const ColorBall({
    super.key,
    required this.color,
    required this.count,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.ballSize,
      height: AppConstants.ballSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Ball(color: color, showShadow: showShadow),
          Text(
            count.toString(),
            style: TextStyle(
              fontFamily: AppConstants.primaryFontFamily,
              fontWeight: AppConstants.extraBoldWeight,
              fontSize: AppConstants.ballCountFontSize,
              color: AppConstants.textPrimaryColor,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.8),
                ),
                Shadow(
                  blurRadius: 4,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
