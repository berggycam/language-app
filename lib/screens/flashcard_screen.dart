import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../models/word_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class FlashcardScreen extends StatefulWidget {
  final WordModel? word;

  const FlashcardScreen({super.key, this.word});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  WordModel? currentWord;
  bool isLoading = true;
  bool isFlipped = false;
  late AnimationController _flipController;
  int currentIndex = 0;
  final List<WordModel> _words = [];
  final List<String> _learnedWords = [];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => isLoading = true);
    
    if (widget.word != null) {
      _words.add(widget.word!);
      setState(() {
        currentWord = widget.word;
        isLoading = false;
      });
    } else {
      // Load random words
      for (int i = 0; i < 5; i++) {
        final wordData = await ApiService.getWordOfTheDay();
        if (wordData != null) {
          _words.add(WordModel.fromJson(wordData));
        }
      }
      
      if (_words.isNotEmpty) {
        setState(() {
          currentWord = _words[0];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
    
    _learnedWords.addAll(await StorageService.getLearnedWordsAsync());
  }

  void _flipCard() {
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => isFlipped = !isFlipped);
  }

  void _nextWord() {
    if (currentIndex < _words.length - 1) {
      setState(() {
        currentIndex++;
        currentWord = _words[currentIndex];
        isFlipped = false;
        _flipController.reset();
      });
    } else {
      _loadWords();
      setState(() {
        currentIndex = 0;
        currentWord = _words.isNotEmpty ? _words[0] : null;
        isFlipped = false;
        _flipController.reset();
      });
    }
  }

  void _markAsLearned() async {
    if (currentWord != null) {
      await StorageService.saveLearnedWord(currentWord!.word);
      await StorageService.updateStreak();
      _nextWord();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Word marked as learned! 🎉'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
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
                        'Flashcards',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadWords,
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: List.generate(
                    _words.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _words.length - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= currentIndex
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Flashcard
              Expanded(
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      : currentWord == null
                          ? Text(
                              'No words available',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            )
                          : GestureDetector(
                              onTap: _flipCard,
                              child: AnimatedBuilder(
                                animation: _flipController,
                                builder: (context, child) {
                                  final angle = _flipController.value * math.pi;
                                  final isFront = angle < math.pi / 2;
                                  
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(angle),
                                    child: isFront
                                        ? _buildFrontCard()
                                        : Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..rotateY(math.pi),
                                            child: _buildBackCard(),
                                          ),
                                  );
                                },
                              ),
                            ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onTap: _nextWord,
                    ),
                    _buildActionButton(
                      icon: Icons.flip,
                      color: AppColors.primary,
                      onTap: _flipCard,
                    ),
                    _buildActionButton(
                      icon: Icons.check,
                      color: Colors.green,
                      onTap: _markAsLearned,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentWord!.word,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (currentWord!.phonetic != null)
            Text(
              currentWord!.phonetic!,
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tap to flip',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentWord!.partOfSpeech,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            currentWord!.firstDefinition,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          if (currentWord!.exampleSentences.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentWord!.exampleSentences[0],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

