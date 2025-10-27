import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive_utils.dart';

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
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(
          ResponsiveUtils.getButtonPadding(context),
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
          Text(
            icon, 
            style: TextStyle(fontSize: ResponsiveUtils.getResponsiveIconSize(context))
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, AppConstants.smallSpacing)),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppConstants.primaryFontFamily,
                fontWeight: AppConstants.semiBoldWeight,
                fontSize: ResponsiveUtils.getBodyFontSize(context),
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
