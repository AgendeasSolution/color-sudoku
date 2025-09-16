import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class ModalButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const ModalButton({
    super.key,
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
          const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 18,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.modalButtonBorderRadius),
          ),
        ),
        side: MaterialStateProperty.all(
          const BorderSide(
            color: Color(0xFF4FD1C7),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontSize: AppConstants.bodyFontSize,
          fontWeight: AppConstants.semiBoldWeight,
          color: AppConstants.textPrimaryColor,
        ),
      ),
    );
  }
}
