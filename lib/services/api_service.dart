import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String dictionaryApiBase = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const String randomWordApi = 'https://random-word-api.herokuapp.com/word?number=1';
  
  // Get word definition from Free Dictionary API
  static Future<Map<String, dynamic>?> getWordDefinition(String word) async {
    try {
      final response = await http.get(
        Uri.parse('$dictionaryApiBase/$word'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching word definition: $e');
      return null;
    }
  }

  // Get random word
  static Future<String?> getRandomWord() async {
    try {
      final response = await http.get(Uri.parse(randomWordApi));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data[0] as String;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching random word: $e');
      return null;
    }
  }

  // Get word of the day (using random word for demo)
  static Future<Map<String, dynamic>?> getWordOfTheDay() async {
    final word = await getRandomWord();
    if (word != null) {
      return await getWordDefinition(word);
    }
    return null;
  }
}

