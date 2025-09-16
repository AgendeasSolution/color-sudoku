import 'package:shared_preferences/shared_preferences.dart';

class LevelProgressionService {
  static const String _unlockedLevelsKey = 'unlocked_levels';
  static const String _completedLevelsKey = 'completed_levels';
  
  // By default, only level 1 (index 0) is unlocked
  static const int _defaultUnlockedLevels = 1;

  /// Get the highest unlocked level (0-based index)
  static Future<int> getHighestUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedLevelsKey) ?? _defaultUnlockedLevels - 1;
  }

  /// Get all unlocked levels (0-based indices)
  static Future<List<int>> getUnlockedLevels() async {
    final highestUnlocked = await getHighestUnlockedLevel();
    return List.generate(highestUnlocked + 1, (index) => index);
  }

  /// Check if a specific level is unlocked (0-based index)
  static Future<bool> isLevelUnlocked(int levelIndex) async {
    final highestUnlocked = await getHighestUnlockedLevel();
    return levelIndex <= highestUnlocked;
  }

  /// Check if a specific level is completed (0-based index)
  static Future<bool> isLevelCompleted(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final completedLevels = prefs.getStringList(_completedLevelsKey) ?? [];
    return completedLevels.contains(levelIndex.toString());
  }

  /// Mark a level as completed and unlock the next level
  static Future<void> completeLevel(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Add to completed levels
    final completedLevels = prefs.getStringList(_completedLevelsKey) ?? [];
    if (!completedLevels.contains(levelIndex.toString())) {
      completedLevels.add(levelIndex.toString());
      await prefs.setStringList(_completedLevelsKey, completedLevels);
    }
    
    // Unlock next level if it exists
    final currentHighest = await getHighestUnlockedLevel();
    if (levelIndex == currentHighest) {
      final nextLevel = levelIndex + 1;
      await prefs.setInt(_unlockedLevelsKey, nextLevel);
    }
  }

  /// Reset all progress (for testing or reset functionality)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedLevelsKey);
    await prefs.remove(_completedLevelsKey);
  }

  /// Get all completed levels (0-based indices)
  static Future<List<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final completedLevels = prefs.getStringList(_completedLevelsKey) ?? [];
    return completedLevels.map((e) => int.parse(e)).toList();
  }
}
