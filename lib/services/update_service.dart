import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class UpdateService {
  // App Store IDs
  static const String _iosAppId = '6754686196';
  static const String _androidPackageName = 'com.fgtp.color_sudoku';
  
  // Store URLs
  static const String _iosStoreUrl = 'https://apps.apple.com/us/app/color-sudoku-color-puzzle/id6754686196';
  static const String _androidStoreUrl = 'https://play.google.com/store/apps/details?id=com.fgtp.color_sudoku';

  /// Get current app version
  /// Note: Update AppConstants.appVersion when you update version in pubspec.yaml
  static Future<String> getCurrentVersion() async {
    return AppConstants.appVersion;
  }

  /// Check for updates on iOS using App Store API
  static Future<String?> getLatestIOSVersion() async {
    try {
      final url = Uri.parse('https://itunes.apple.com/lookup?id=$_iosAppId');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final version = data['results'][0]['version'] as String?;
          return version;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error checking iOS version: $e');
      return null;
    }
  }

  /// Check for updates on Android by parsing Play Store page
  static Future<String?> getLatestAndroidVersion() async {
    try {
      final url = Uri.parse('https://play.google.com/store/apps/details?id=$_androidPackageName');
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final html = response.body;
        
        // Try multiple patterns to find version
        final patterns = [
          // Pattern 1: Current Version in div
          RegExp(r'Current Version</div><span[^>]*>([\d.]+)</span>'),
          // Pattern 2: Version in script JSON
          RegExp(r'"version":"([\d.]+)"'),
          // Pattern 3: Version in script with versionName
          RegExp(r'"versionName":"([\d.]+)"'),
          // Pattern 4: Version in meta content
          RegExp(r'Version ([\d.]+)'),
          // Pattern 5: Version in data attribute
          RegExp(r'data-version="([\d.]+)"'),
          // Pattern 6: Version in span with class
          RegExp(r'<span[^>]*class="[^"]*version[^"]*"[^>]*>([\d.]+)</span>', caseSensitive: false),
        ];

        for (final pattern in patterns) {
          final match = pattern.firstMatch(html);
          if (match != null && match.groupCount >= 1) {
            final version = match.group(1);
            if (version != null && version.isNotEmpty) {
              return version;
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error checking Android version: $e');
      return null;
    }
  }

  /// Check if update is available
  static Future<bool> isUpdateAvailable() async {
    try {
      final currentVersion = await getCurrentVersion();
      String? latestVersion;

      if (Platform.isIOS) {
        latestVersion = await getLatestIOSVersion();
      } else if (Platform.isAndroid) {
        latestVersion = await getLatestAndroidVersion();
      } else {
        return false; // Not supported on other platforms
      }

      if (latestVersion == null) {
        return false; // Could not determine latest version
      }

      return _compareVersions(latestVersion, currentVersion) > 0;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return false;
    }
  }

  /// Compare two version strings (e.g., "1.0.2" vs "1.0.3")
  /// Returns: 1 if version1 > version2, -1 if version1 < version2, 0 if equal
  static int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad shorter version with zeros
    while (v1Parts.length < v2Parts.length) v1Parts.add(0);
    while (v2Parts.length < v1Parts.length) v2Parts.add(0);

    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }

  /// Get store URL for current platform
  static String getStoreUrl() {
    if (Platform.isIOS) {
      return _iosStoreUrl;
    } else if (Platform.isAndroid) {
      return _androidStoreUrl;
    }
    return '';
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}
