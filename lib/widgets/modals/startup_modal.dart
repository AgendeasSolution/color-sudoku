import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'modal_container.dart';

class StartupModal extends StatelessWidget {
  final VoidCallback onClose;

  const StartupModal({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ModalContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              _buildHeader(),
              const SizedBox(height: AppConstants.largeSpacing),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoSection(
                        '',
                        'Fill the grid with colors. Each row and column must have one of each color, and no two adjacent cells (including diagonals) can be the same color.',
                      ),
                      const SizedBox(height: AppConstants.largeSpacing),
                      _buildHowToPlaySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppConstants.logoBlue,
              AppConstants.logoPurple,
              AppConstants.logoOrange,
            ],
          ).createShader(bounds),
          child: const Text(
            'How to Play',
            style: TextStyle(
              fontFamily: AppConstants.primaryFontFamily,
              fontSize: AppConstants.sectionTitleFontSize,
              fontWeight: AppConstants.boldWeight,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.logoBlue.withOpacity(0.3),
                  AppConstants.logoPurple.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onClose,
                child: const Icon(Icons.close, size: 16, color: AppConstants.textPrimaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: AppConstants.secondaryFontFamily,
            fontSize: 14,
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
