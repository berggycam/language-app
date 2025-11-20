import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewWord> _reviewWords = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showAnswer = false;
  int _correctCount = 0;
  int _totalReviewed = 0;

  @override
  void initState() {
    super.initState();
    _loadReviewWords();
  }

  Future<void> _loadReviewWords() async {
    setState(() => _isLoading = true);
    
    final learnedWords = await StorageService.getLearnedWordsAsync();
    final reviewList = <ReviewWord>[];
    
    for (final word in learnedWords) {
      final lastReviewed = await StorageService.getWordLastReviewed(word);
      final reviewCount = await StorageService.getWordReviewCount(word);
      final nextReview = await StorageService.getWordNextReview(word);
      
      final now = DateTime.now();
      final nextReviewDate = nextReview != null 
          ? DateTime.parse(nextReview) 
          : now.subtract(const Duration(days: 1));
      
      // Add to review if it's time to review (spaced repetition)
      if (nextReviewDate.isBefore(now) || nextReviewDate.isAtSameMomentAs(now)) {
        final wordData = await ApiService.getWordDefinition(word);
        if (wordData != null) {
          reviewList.add(ReviewWord(
            word: WordModel.fromJson(wordData),
            lastReviewed: lastReviewed,
            reviewCount: reviewCount,
          ));
        }
      }
    }
    
    // If no words need review, show some random learned words
    if (reviewList.isEmpty && learnedWords.isNotEmpty) {
      for (int i = 0; i < 5 && i < learnedWords.length; i++) {
        final wordData = await ApiService.getWordDefinition(learnedWords[i]);
        if (wordData != null) {
          reviewList.add(ReviewWord(
            word: WordModel.fromJson(wordData),
            lastReviewed: null,
            reviewCount: 0,
          ));
        }
      }
    }
    
    setState(() {
      _reviewWords = reviewList;
      _isLoading = false;
    });
  }

  Future<void> _handleReview(bool remembered) async {
    final currentWord = _reviewWords[_currentIndex];
    
    if (remembered) {
      _correctCount++;
      await StorageService.updateWordReview(
        currentWord.word.word,
        remembered: true,
      );
      await StorageService.addXP(15);
    } else {
      await StorageService.updateWordReview(
        currentWord.word.word,
        remembered: false,
      );
    }
    
    _totalReviewed++;
    
    if (_currentIndex < _reviewWords.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final accuracy = _totalReviewed > 0 
        ? (_correctCount / _totalReviewed * 100).toInt() 
        : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Review Complete!',
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
                  '$accuracy%',
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
              'You reviewed $_totalReviewed words',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount correct answers',
              style: GoogleFonts.poppins(
                fontSize: 14,
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
                _correctCount = 0;
                _totalReviewed = 0;
                _showAnswer = false;
              });
              _loadReviewWords();
            },
            child: Text(
              'Review More',
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
                        'Review',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1}/${_reviewWords.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
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
                    value: _reviewWords.isNotEmpty
                        ? (_currentIndex + 1) / _reviewWords.length
                        : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Review Card
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _reviewWords.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 80,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No words to review!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All your words are up to date',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
                                        'Do you remember this word?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        _reviewWords[_currentIndex].word.word,
                                        style: GoogleFonts.poppins(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (_reviewWords[_currentIndex]
                                              .word
                                              .phonetic !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _reviewWords[_currentIndex]
                                              .word
                                              .phonetic!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      if (_showAnswer) ...[
                                        const SizedBox(height: 32),
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Definition:',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _reviewWords[_currentIndex]
                                                    .word
                                                    .firstDefinition,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                  height: 1.6,
                                                ),
                                              ),
                                            ],
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

                                // Action Buttons
                                if (!_showAnswer)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          margin: EdgeInsets.zero,
                                          onTap: () {
                                            setState(() => _showAnswer = true);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.visibility,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Show Answer',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      .animate()
                                      .fadeIn(delay: 200.ms, duration: 400.ms)
                                      .slideY(begin: 0.2)
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          margin: EdgeInsets.zero,
                                          onTap: () => _handleReview(false),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Forgot',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          margin: EdgeInsets.zero,
                                          onTap: () => _handleReview(true),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: AppGradients
                                                  .successGradient,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Remembered',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      .animate()
                                      .fadeIn(delay: 400.ms, duration: 400.ms)
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

class ReviewWord {
  final WordModel word;
  final String? lastReviewed;
  final int reviewCount;

  ReviewWord({
    required this.word,
    this.lastReviewed,
    required this.reviewCount,
  });
}

