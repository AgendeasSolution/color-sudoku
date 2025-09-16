import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class GameButton extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const GameButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 450;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppConstants.mediumSpacing,
            vertical: AppConstants.smallSpacing,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
        side: MaterialStateProperty.all(
          BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: AppConstants.cellBorderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: AppConstants.smallIconSize)),
          const SizedBox(width: AppConstants.smallSpacing),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFontFamily,
                fontWeight: AppConstants.semiBoldWeight,
                color: AppConstants.textPrimaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
