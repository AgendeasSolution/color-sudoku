import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'modal_container.dart';
import 'modal_button.dart';

class StartupModal extends StatelessWidget {
  final VoidCallback onClose;

  const StartupModal({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ModalContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                '🎯 Mission',
                'Fill the grid with colors. Each row and column must have one of each color, and no two adjacent cells (including diagonals) can be the same color.',
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildHowToPlaySection(),
              const SizedBox(height: AppConstants.extraLargeSpacing),
              ModalButton(
                text: 'Got it',
                color: AppConstants.successColor,
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: AppConstants.sectionTitleFontSize,
            fontWeight: AppConstants.boldWeight,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(
            fontFamily: AppConstants.secondaryFontFamily,
            fontSize: AppConstants.bodyFontSize,
            color: AppConstants.textTertiaryColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildHowToPlaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎮 How to Play',
          style: TextStyle(
            fontFamily: AppConstants.primaryFontFamily,
            fontSize: AppConstants.sectionTitleFontSize,
            fontWeight: AppConstants.boldWeight,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 15),
        _buildInstructionItem('🎨', 'Click on a color from the palette'),
        _buildInstructionItem('✨', 'The highlighted cell shows where to place it'),
        _buildInstructionItem('🐍', 'Follow the snake pattern to fill the grid'),
        _buildInstructionItem('💡', 'Use "Solution" if you get stuck'),
        _buildInstructionItem('🔄', 'Use "Reset" to start over'),
      ],
    );
  }

  Widget _buildInstructionItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: AppConstants.mediumIconSize)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppConstants.secondaryFontFamily,
                fontSize: AppConstants.smallFontSize,
                color: AppConstants.textTertiaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
