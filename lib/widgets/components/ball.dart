import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class Ball extends StatelessWidget {
  final Color color;
  final bool showShadow;
  
  const Ball({
    super.key,
    required this.color,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: AppConstants.ballShadowBlur,
            offset: const Offset(0, AppConstants.ballShadowOffset),
          ),
        ] : null,
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.7),
                  radius: 0.8,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
