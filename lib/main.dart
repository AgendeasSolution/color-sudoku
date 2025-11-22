import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/other_game_screen.dart';
import 'services/audio_service.dart';
import 'constants/app_constants.dart';
import 'widgets/components/update_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize OneSignal
  OneSignal.initialize("efc06e02-58d6-416a-9f9d-a3f9559cd734");
  
  // Request permission to send push notifications (iOS only)
  OneSignal.Notifications.requestPermission(true);
  
  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();
  
  // Initialize audio service
  await AudioService().initialize();
  
  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ColorSudokuApp());
}

class ColorSudokuApp extends StatefulWidget {
  const ColorSudokuApp({super.key});

  @override
  State<ColorSudokuApp> createState() => _ColorSudokuAppState();
}

class _ColorSudokuAppState extends State<ColorSudokuApp> {
  bool _showSplashScreen = true;
  bool _showGameScreen = false;
  bool _showOtherGameScreen = false;
  int _selectedLevel = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();
  int _updateBannerTrigger = 0;

  void _onSplashComplete() {
    setState(() {
      _showSplashScreen = false;
    });
  }

  void _onLevelSelected(int levelIndex) {
    setState(() {
      _selectedLevel = levelIndex;
      _showGameScreen = true;
    });
  }

  void _goHome() {
    setState(() {
      _showGameScreen = false;
      _showOtherGameScreen = false;
    });
    // Refresh level progression when returning to home
    _homeScreenKey.currentState?.refreshLevelProgression();
  }

  void _onOtherGameSelected() {
    setState(() {
      _showOtherGameScreen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryAccentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: AppConstants.secondaryFontFamily,
      ),
      home: _showSplashScreen
          ? SplashScreen(onSplashComplete: _onSplashComplete)
          : _buildAppWithUpdateBanner(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildAppWithUpdateBanner() {
    final currentScreen = _showGameScreen
        ? GameScreen(
            initialLevel: _selectedLevel,
            onGoHome: _goHome,
          )
        : _showOtherGameScreen
            ? OtherGameScreen(
                onGoHome: _goHome,
              )
            : HomeScreen(
                key: _homeScreenKey,
                onLevelSelected: _onLevelSelected,
                onOtherGameSelected: _onOtherGameSelected,
                onTestUpdateBanner: () {
                  // Increment counter to trigger the banner
                  setState(() {
                    _updateBannerTrigger++;
                  });
                },
              );

    return Stack(
      children: [
        currentScreen,
        // Backdrop overlay for tap outside to dismiss
        if (_updateBannerTrigger > 0)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Dismiss banner when tapping outside
                setState(() {
                  _updateBannerTrigger = 0;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        // Update banner positioned at bottom - full width, no margin
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: UpdateBanner(
            forceShow: _updateBannerTrigger > 0,
            triggerKey: _updateBannerTrigger,
            onDismiss: () {
              setState(() {
                _updateBannerTrigger = 0;
              });
            },
          ),
        ),
      ],
    );
  }
}
