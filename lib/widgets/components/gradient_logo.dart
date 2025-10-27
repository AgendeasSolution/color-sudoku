import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';

class GradientLogo extends StatelessWidget {
  final double? fontSize;
  final String? subtitle;
  final double? subtitleFontSize;
  final TextAlign textAlign;
  final bool showSubtitle;

  const GradientLogo({
    super.key,
    this.fontSize,
    this.subtitle,
    this.subtitleFontSize,
    this.textAlign = TextAlign.center,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main logo text with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF63B3ED), // #63b3ed (blue)
              Color(0xFF9F7AEA), // #9f7aea (purple)
              Color(0xFFED8936), // #ed8936 (orange)
              Color(0xFF38B2AC), // #38b2ac (teal)
            ],
            stops: [0.0, 0.33, 0.66, 1.0],
          ).createShader(bounds),
          child: Text(
            AppConstants.appName,
            textAlign: textAlign,
            style: GoogleFonts.orbitron(
              fontSize: fontSize ?? AppConstants.titleFontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white, // This will be overridden by the gradient
              shadows: [
                const Shadow(
                  blurRadius: 20,
                  color: Color(0xCC63B3ED), // rgba(99, 179, 237, 0.8) (blue glow)
                ),
                const Shadow(
                  blurRadius: 40,
                  color: Color(0x6663B3ED), // rgba(99, 179, 237, 0.4) (lighter blue glow)
                ),
              ],
            ),
          ),
        ),
        // Subtitle
        if (showSubtitle) ...[
          const SizedBox(height: 1.0),
          Text(
            subtitle ?? AppConstants.appDescription,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: AppConstants.secondaryFontFamily,
              fontSize: subtitleFontSize ?? AppConstants.subtitleFontSize,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}
