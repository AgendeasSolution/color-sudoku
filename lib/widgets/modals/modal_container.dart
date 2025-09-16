import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class ModalContainer extends StatelessWidget {
  final Widget child;

  const ModalContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.modalMargin),
      padding: const EdgeInsets.all(AppConstants.modalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.modalBorderRadius),
        border: Border.all(
          color: AppConstants.borderColor,
          width: AppConstants.modalBorderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.cardBackgroundColor.withOpacity(0.95),
            AppConstants.cardSecondaryColor.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: AppConstants.modalShadowBlur,
            offset: const Offset(0, AppConstants.modalShadowOffset),
          ),
        ],
      ),
      child: child,
    );
  }
}
