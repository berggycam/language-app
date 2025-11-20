import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<WordModel> _words = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    final words = <WordModel>[];
    
    for (int i = 0; i < 5; i++) {
      final wordData = await ApiService.getWordOfTheDay();
      if (wordData != null) {
        words.add(WordModel.fromJson(wordData));
      }
    }
    
    setState(() {
      _words = words;
      _isLoading = false;
    });
  }

  void _checkAnswer(String answer) {
    if (_showResult) return;
    
    final currentWord = _words[_currentIndex];
    final isCorrect = answer == currentWord.firstDefinition;
    
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      if (isCorrect) {
        _score++;
      }
    });

    if (isCorrect) {
      StorageService.addXP(20);
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() async {
    await StorageService.incrementTodayPractice();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Practice Complete!',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_score/${_words.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You scored ${(_score / _words.length * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _selectedAnswer = null;
                _showResult = false;
              });
              _loadWords();
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateOptions(WordModel word) {
    final options = [word.firstDefinition];
    // Add dummy options (in real app, these would come from API)
    options.addAll([
      'A state of being happy',
      'To move quickly',
      'A type of food',
    ]);
    options.shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Practice',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$_score/${_words.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _words.length,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Question
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _words.isEmpty
                        ? Center(
                            child: Text(
                              'No words available',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                GlassCard(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Text(
                                        'What does this word mean?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        _words[_currentIndex].word,
                                        style: GoogleFonts.poppins(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (_words[_currentIndex].phonetic != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _words[_currentIndex].phonetic!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .scale(begin: const Offset(0.9, 0.9)),

                                const SizedBox(height: 24),

                                // Options
                                ..._generateOptions(_words[_currentIndex])
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final option = entry.value;
                                  final index = entry.key;
                                  final isSelected = _selectedAnswer == option;
                                  final isCorrectOption =
                                      option == _words[_currentIndex].firstDefinition;

                                  Color? borderColor;
                                  Color? backgroundColor;
                                  if (_showResult) {
                                    if (isCorrectOption) {
                                      borderColor = Colors.green;
                                      backgroundColor = Colors.green.withOpacity(0.1);
                                    } else if (isSelected && !isCorrectOption) {
                                      borderColor = Colors.red;
                                      backgroundColor = Colors.red.withOpacity(0.1);
                                    }
                                  }

                                  return GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    onTap: () => _checkAnswer(option),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: borderColor != null
                                            ? Border.all(color: borderColor, width: 2)
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                String.fromCharCode(65 + index),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (_showResult && isCorrectOption)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                          if (_showResult &&
                                              isSelected &&
                                              !isCorrectOption)
                                            const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                        duration: 300.ms,
                                        delay: (index * 100).ms,
                                      )
                                      .slideX(begin: -0.1);
                                }).toList(),

                                const SizedBox(height: 24),

                                // Next Button
                                if (_showResult)
                                  GradientButton(
                                    text: _currentIndex < _words.length - 1
                                        ? 'Next Question'
                                        : 'View Results',
                                    icon: Icons.arrow_forward,
                                    onPressed: _nextQuestion,
                                  )
                                      .animate()
                                      .fadeIn(duration: 400.ms)
                                      .slideY(begin: 0.2),

                                const SizedBox(height: 40),
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
}

