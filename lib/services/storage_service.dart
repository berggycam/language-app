import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _learnedWordsKey = 'learned_words';
  static const String _streakKey = 'streak';
  static const String _lastPracticeKey = 'last_practice';
  static const String _totalWordsKey = 'total_words';
  static const String _selectedLanguageKey = 'selected_language';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _totalXPKey = 'total_xp';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _dailyPracticeGoalKey = 'daily_practice_goal';
  static const String _todayWordsKey = 'today_words';
  static const String _todayPracticeKey = 'today_practice';
  static const String _todayDateKey = 'today_date';

  static Future<void> saveLearnedWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final words = await getLearnedWordsAsync();
    if (!words.contains(word)) {
      words.add(word);
      await prefs.setStringList(_learnedWordsKey, words);
      await incrementTotalWords();
    }
  }


  static Future<List<String>> getLearnedWordsAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_learnedWordsKey) ?? [];
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPractice = prefs.getString(_lastPracticeKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastPractice == today) {
      return; // Already practiced today
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1))
        .toIso8601String().split('T')[0];
    
    int currentStreak = prefs.getInt(_streakKey) ?? 0;
    
    if (lastPractice == yesterday) {
      currentStreak++;
    } else if (lastPractice != today) {
      currentStreak = 1; // Reset streak
    }

    await prefs.setInt(_streakKey, currentStreak);
    await prefs.setString(_lastPracticeKey, today);
  }

  static Future<int> getTotalWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalWordsKey) ?? 0;
  }

  static Future<String?> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey);
  }

  static Future<void> setSelectedLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, language);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<int> getTotalXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXPKey) ?? 0;
  }

  static Future<void> addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalXPKey) ?? 0;
    await prefs.setInt(_totalXPKey, current + xp);
  }

  static Future<void> incrementTotalWords() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalWordsKey) ?? 0;
    await prefs.setInt(_totalWordsKey, current + 1);
    // Add XP when learning a word
    await addXP(10);
    // Increment today's word count
    await _incrementTodayWords();
  }

  // Daily Goals
  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? 10;
  }

  static Future<void> setDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, goal);
  }

  static Future<int> getDailyPracticeGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyPracticeGoalKey) ?? 1;
  }

  static Future<void> setDailyPracticeGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyPracticeGoalKey, goal);
  }

  static Future<int> getTodayWordsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_todayDateKey);
    
    if (lastDate != today) {
      await prefs.setInt(_todayWordsKey, 0);
      await prefs.setString(_todayDateKey, today);
      return 0;
    }
    
    return prefs.getInt(_todayWordsKey) ?? 0;
  }

  static Future<void> _incrementTodayWords() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_todayDateKey);
    
    if (lastDate != today) {
      await prefs.setInt(_todayWordsKey, 1);
      await prefs.setString(_todayDateKey, today);
    } else {
      final current = prefs.getInt(_todayWordsKey) ?? 0;
      await prefs.setInt(_todayWordsKey, current + 1);
    }
  }

  static Future<int> getTodayPracticeCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_todayDateKey);
    
    if (lastDate != today) {
      return 0;
    }
    
    return prefs.getInt(_todayPracticeKey) ?? 0;
  }

  static Future<void> incrementTodayPractice() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_todayDateKey);
    
    if (lastDate != today) {
      await prefs.setInt(_todayPracticeKey, 1);
      await prefs.setString(_todayDateKey, today);
    } else {
      final current = prefs.getInt(_todayPracticeKey) ?? 0;
      await prefs.setInt(_todayPracticeKey, current + 1);
    }
  }

  // Spaced Repetition System
  static Future<String?> getWordLastReviewed(String word) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('word_${word}_last_reviewed');
  }

  static Future<int> getWordReviewCount(String word) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('word_${word}_review_count') ?? 0;
  }

  static Future<String?> getWordNextReview(String word) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('word_${word}_next_review');
  }

  static Future<void> updateWordReview(
    String word, {
    required bool remembered,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final reviewCount = await getWordReviewCount(word);
    
    // Spaced repetition intervals: 1 day, 3 days, 7 days, 14 days, 30 days
    final intervals = [1, 3, 7, 14, 30];
    int nextInterval;
    
    if (remembered) {
      final newCount = reviewCount + 1;
      nextInterval = newCount < intervals.length 
          ? intervals[newCount] 
          : intervals.last;
      await prefs.setInt('word_${word}_review_count', newCount);
    } else {
      // Reset if forgotten
      nextInterval = intervals[0];
      await prefs.setInt('word_${word}_review_count', 0);
    }
    
    final nextReview = now.add(Duration(days: nextInterval));
    await prefs.setString('word_${word}_last_reviewed', now.toIso8601String());
    await prefs.setString('word_${word}_next_review', nextReview.toIso8601String());
  }
}

