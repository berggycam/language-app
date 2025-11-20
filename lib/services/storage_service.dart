import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _learnedWordsKey = 'learned_words';
  static const String _streakKey = 'streak';
  static const String _lastPracticeKey = 'last_practice';
  static const String _totalWordsKey = 'total_words';
  static const String _selectedLanguageKey = 'selected_language';

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

  static Future<void> incrementTotalWords() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalWordsKey) ?? 0;
    await prefs.setInt(_totalWordsKey, current + 1);
  }

  static Future<String?> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey);
  }

  static Future<void> setSelectedLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, language);
  }
}

