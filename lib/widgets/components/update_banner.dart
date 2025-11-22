import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/update_service.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive_utils.dart';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> with SingleTickerProviderStateMixin {
  bool _isUpdateAvailable = false;
  bool _isDismissed = false;
  bool _isChecking = true;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start below screen
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _checkForUpdate();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      final isAvailable = await UpdateService.isUpdateAvailable();
      if (mounted) {
        setState(() {
          _isUpdateAvailable = isAvailable;
          _isChecking = false;
        });
        if (_isUpdateAvailable) {
          _slideController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _dismissBanner() {
    setState(() {
      _isDismissed = true;
    });
    _slideController.reverse();
  }

  Future<void> _openStore() async {
    final storeUrl = UpdateService.getStoreUrl();
    if (storeUrl.isNotEmpty) {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking || !_isUpdateAvailable || _isDismissed) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.only(
          left: ResponsiveUtils.getResponsiveSpacing(context, 16),
          right: ResponsiveUtils.getResponsiveSpacing(context, 16),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 76), // 60 (ad banner) + 16 (spacing)
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryAccentColor,
              AppConstants.logoPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryAccentColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openStore,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 16)),
              child: Row(
                children: [
                  // Update icon
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 8)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.system_update,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context) * 1.2,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                  // Update text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Update Available',
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFontFamily,
                            fontSize: ResponsiveUtils.getBodyFontSize(context) * 1.1,
                            fontWeight: AppConstants.boldWeight,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                        Text(
                          'Tap to update to the latest version',
                          style: TextStyle(
                            fontFamily: AppConstants.secondaryFontFamily,
                            fontSize: ResponsiveUtils.getBodyFontSize(context) * 0.85,
                            fontWeight: AppConstants.regularWeight,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  IconButton(
                    onPressed: _dismissBanner,
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

