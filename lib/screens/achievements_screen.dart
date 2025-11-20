import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  int _unlockedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final streak = await StorageService.getStreak();
    final words = await StorageService.getTotalWords();
    final xp = await StorageService.getTotalXP();

    _achievements = [
      Achievement(
        id: 'first_word',
        title: 'First Steps',
        description: 'Learn your first word',
        icon: Icons.star,
        gradient: [AppColors.primary, AppColors.secondary],
        unlocked: words > 0,
        progress: words > 0 ? 1.0 : 0.0,
        target: 1,
        current: words > 0 ? 1 : 0,
      ),
      Achievement(
        id: 'word_master',
        title: 'Word Master',
        description: 'Learn 10 words',
        icon: Icons.book,
        gradient: [AppColors.secondary, AppColors.accent],
        unlocked: words >= 10,
        progress: (words / 10).clamp(0.0, 1.0),
        target: 10,
        current: words,
      ),
      Achievement(
        id: 'vocabulary_builder',
        title: 'Vocabulary Builder',
        description: 'Learn 50 words',
        icon: Icons.library_books,
        gradient: [AppColors.accent, AppColors.primary],
        unlocked: words >= 50,
        progress: (words / 50).clamp(0.0, 1.0),
        target: 50,
        current: words,
      ),
      Achievement(
        id: 'word_collector',
        title: 'Word Collector',
        description: 'Learn 100 words',
        icon: Icons.collections_bookmark,
        gradient: [AppColors.primary, AppColors.accent],
        unlocked: words >= 100,
        progress: (words / 100).clamp(0.0, 1.0),
        target: 100,
        current: words,
      ),
      Achievement(
        id: 'streak_3',
        title: 'On Fire',
        description: 'Maintain a 3-day streak',
        icon: Icons.local_fire_department,
        gradient: [Colors.orange, Colors.red],
        unlocked: streak >= 3,
        progress: (streak / 3).clamp(0.0, 1.0),
        target: 3,
        current: streak,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department,
        gradient: [Colors.red, Colors.deepOrange],
        unlocked: streak >= 7,
        progress: (streak / 7).clamp(0.0, 1.0),
        target: 7,
        current: streak,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Streak Master',
        description: 'Maintain a 30-day streak',
        icon: Icons.emoji_events,
        gradient: [Colors.amber, Colors.orange],
        unlocked: streak >= 30,
        progress: (streak / 30).clamp(0.0, 1.0),
        target: 30,
        current: streak,
      ),
      Achievement(
        id: 'xp_1000',
        title: 'XP Collector',
        description: 'Earn 1,000 XP',
        icon: Icons.stars,
        gradient: [AppColors.primary, AppColors.accent],
        unlocked: xp >= 1000,
        progress: (xp / 1000).clamp(0.0, 1.0),
        target: 1000,
        current: xp,
      ),
      Achievement(
        id: 'xp_5000',
        title: 'XP Master',
        description: 'Earn 5,000 XP',
        icon: Icons.workspace_premium,
        gradient: [AppColors.accent, AppColors.primary],
        unlocked: xp >= 5000,
        progress: (xp / 5000).clamp(0.0, 1.0),
        target: 5000,
        current: xp,
      ),
      Achievement(
        id: 'dedicated_learner',
        title: 'Dedicated Learner',
        description: 'Learn 5 words in one day',
        icon: Icons.school,
        gradient: [AppColors.secondary, AppColors.primary],
        unlocked: false, // This would need daily tracking
        progress: 0.0,
        target: 5,
        current: 0,
      ),
    ];

    _unlockedCount = _achievements.where((a) => a.unlocked).length;

    setState(() => _isLoading = false);
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
                        'Achievements',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_unlockedCount/${_achievements.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(_unlockedCount / _achievements.length * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _unlockedCount / _achievements.length,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.2),
              ),

              const SizedBox(height: 24),

              // Achievements Grid
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _achievements.length,
                        itemBuilder: (context, index) {
                          return _buildAchievementCard(
                            _achievements[index],
                            index,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: achievement.unlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: achievement.gradient,
                    )
                  : null,
              color: achievement.unlocked
                  ? null
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: achievement.unlocked
                  ? [
                      BoxShadow(
                        color: achievement.gradient[0].withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              size: 36,
              color: achievement.unlocked
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
          )
              .animate()
              .scale(
                delay: (index * 50).ms,
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 300.ms, delay: (index * 50).ms),

          const SizedBox(height: 12),

          // Title
          Text(
            achievement.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: achievement.unlocked
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Description
          Text(
            achievement.description,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Progress
          if (!achievement.unlocked)
            Column(
              children: [
                Text(
                  '${achievement.current}/${achievement.target}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.gradient[0].withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Unlocked',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideY(begin: 0.2);
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final bool unlocked;
  final double progress;
  final int target;
  final int current;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.unlocked,
    required this.progress,
    required this.target,
    required this.current,
  });
}

