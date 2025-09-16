import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.borderWidth = 2.0,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        children: [
          // Gradient border effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF63B3ED), // #63b3ed (blue)
                  Color(0xFF9F7AEA), // #9f7aea (purple)
                  Color(0xFFED8936), // #ed8936 (orange)
                  Color(0xFF38B2AC), // #38b2ac (teal)
                ],
                stops: [0.0, 0.33, 0.66, 1.0],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(borderWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius - borderWidth),
                color: Colors.transparent,
              ),
            ),
          ),
          // Main content with background
          Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                begin: Alignment(0.7, -0.7), // 145deg equivalent
                end: Alignment(-0.7, 0.7),
                colors: [AppConstants.gameContainerBgStart, AppConstants.gameContainerBgEnd],
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
