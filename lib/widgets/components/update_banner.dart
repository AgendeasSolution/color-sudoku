import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/update_service.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive_utils.dart';

class UpdateBanner extends StatefulWidget {
  final bool forceShow;
  final int triggerKey;
  final VoidCallback? onDismiss;
  
  const UpdateBanner({
    super.key,
    this.forceShow = false,
    this.triggerKey = 0,
    this.onDismiss,
  });

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
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start below screen
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    if (widget.forceShow) {
      // Force show for testing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isUpdateAvailable = true;
            _isChecking = false;
            _isDismissed = false;
          });
          _slideController.forward();
        }
      });
    } else {
      _checkForUpdate();
    }
  }

  @override
  void didUpdateWidget(UpdateBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger banner when triggerKey changes and forceShow is true
    if (widget.forceShow && widget.triggerKey != oldWidget.triggerKey && widget.triggerKey > 0) {
      // Force show when triggered
      setState(() {
        _isUpdateAvailable = true;
        _isChecking = false;
        _isDismissed = false;
      });
      _slideController.forward();
    }
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
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
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
      child: GestureDetector(
        onTap: () {
          // Prevent tap from propagating to backdrop
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.backgroundColor,
                AppConstants.secondaryBackgroundColor,
                AppConstants.tertiaryBackgroundColor,
                AppConstants.backgroundColor,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(
                color: AppConstants.primaryAccentColor.withOpacity(0.5),
                width: 2,
              ),
              left: BorderSide(
                color: AppConstants.primaryAccentColor.withOpacity(0.5),
                width: 2,
              ),
              right: BorderSide(
                color: AppConstants.primaryAccentColor.withOpacity(0.5),
                width: 2,
              ),
            ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: AppConstants.primaryAccentColor.withOpacity(0.15),
              blurRadius: 50,
              spreadRadius: 0,
              offset: const Offset(0, -15),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: ResponsiveUtils.getResponsiveSpacing(context, 20),
              right: ResponsiveUtils.getResponsiveSpacing(context, 20),
              top: ResponsiveUtils.getResponsiveSpacing(context, 16),
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Heading
                Text(
                  'Update Available!',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFontFamily,
                    fontSize: ResponsiveUtils.getTitleFontSize(context) * 1.15,
                    fontWeight: AppConstants.boldWeight,
                    color: AppConstants.textPrimaryColor,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: AppConstants.primaryAccentColor.withOpacity(0.4),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                
                // App Image
                Container(
                  constraints: BoxConstraints(
                    maxHeight: ResponsiveUtils.isTablet(context) ? 135 : 120,
                    maxWidth: ResponsiveUtils.isTablet(context) ? 225 : 160,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryAccentColor.withOpacity(0.25),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/img/color-sudoku.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image not found
                        return Container(
                          height: ResponsiveUtils.isTablet(context) ? 135 : 120,
                          width: ResponsiveUtils.isTablet(context) ? 225 : 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppConstants.primaryAccentColor,
                                AppConstants.logoPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.system_update,
                            size: ResponsiveUtils.isTablet(context) ? 50 : 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                
                // Description
                Text(
                  'A new version of Color Sudoku is available with exciting features, bug fixes, and performance improvements. Update now to enjoy the best experience!',
                  style: TextStyle(
                    fontFamily: AppConstants.secondaryFontFamily,
                    fontSize: ResponsiveUtils.getBodyFontSize(context) * 1.15,
                    fontWeight: AppConstants.regularWeight,
                    color: AppConstants.textSecondaryColor,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                
                // Buttons Row
                Row(
                  children: [
                    // Do It Later Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _dismissBanner,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            AppConstants.cardBackgroundColor,
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(
                              vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
                            ),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                              side: BorderSide(
                                color: AppConstants.borderColor,
                                width: 2,
                              ),
                            ),
                          ),
                          elevation: MaterialStateProperty.all(0),
                        ),
                        child: Text(
                          'Do It Later',
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFontFamily,
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                            fontWeight: AppConstants.semiBoldWeight,
                            color: AppConstants.textPrimaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    
                    // Install Now Button - Larger width
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: _openStore,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            AppConstants.primaryAccentColor,
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(
                              vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
                            ),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                            ),
                          ),
                          elevation: MaterialStateProperty.all(8),
                          shadowColor: MaterialStateProperty.all(
                            AppConstants.primaryAccentColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download,
                              size: ResponsiveUtils.getResponsiveIconSize(context),
                              color: Colors.white,
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                            Text(
                              'Install Now',
                              style: TextStyle(
                                fontFamily: AppConstants.primaryFontFamily,
                                fontSize: ResponsiveUtils.getBodyFontSize(context),
                                fontWeight: AppConstants.boldWeight,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
