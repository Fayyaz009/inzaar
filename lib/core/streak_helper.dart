import 'package:shared_preferences/shared_preferences.dart';

class StreakHelper {
  static const String _lastVisitKey = 'last_visit_date';
  static const String _streakCountKey = 'streak_count';

  static Future<int> updateAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastVisitStr = prefs.getString(_lastVisitKey);
    int currentStreak = prefs.getInt(_streakCountKey) ?? 0;

    if (lastVisitStr == null) {
      // First time
      currentStreak = 1;
    } else {
      final lastVisit = DateTime.parse(lastVisitStr);
      final difference = today.difference(lastVisit).inDays;

      if (difference == 1) {
        // Consecutive day
        currentStreak++;
      } else if (difference > 1) {
        // Streak broken
        currentStreak = 1;
      }
      // If difference is 0, same day, no change to streak
    }

    await prefs.setString(_lastVisitKey, today.toIso8601String());
    await prefs.setInt(_streakCountKey, currentStreak);

    return currentStreak;
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }
}
