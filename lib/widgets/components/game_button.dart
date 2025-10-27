import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive_utils.dart';

class GameButton extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final double? fixedWidth;

  const GameButton({
    super.key,
    this.icon,
    this.iconData,
    required this.text,
    required this.color,
    required this.onPressed,
    this.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
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
        mainAxisSize: fixedWidth != null ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null)
            Icon(
              iconData,
              size: ResponsiveUtils.getResponsiveIconSize(context),
              color: AppConstants.textPrimaryColor,
            )
          else if (icon != null)
            Text(
              icon!,
              style: TextStyle(fontSize: ResponsiveUtils.getResponsiveIconSize(context)),
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
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    if (fixedWidth != null) {
      return SizedBox(
        width: fixedWidth,
        child: button,
      );
    }

    return button;
  }
}

class GameIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const GameIconButton({
    super.key,
    required this.icon,
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
          EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 12)),
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
      child: Icon(
        icon,
        size: ResponsiveUtils.getResponsiveIconSize(context),
        color: AppConstants.textPrimaryColor,
      ),
    );
  }
}
