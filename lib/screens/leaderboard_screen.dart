import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Time'];
  
  List<LeaderboardUser> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    // Simulate loading leaderboard data
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate mock leaderboard data
    final userXP = await StorageService.getTotalXP();
    final userStreak = await StorageService.getStreak();
    final userName = await StorageService.getUserName() ?? 'You';
    
    _leaderboard = [
      LeaderboardUser(
        name: 'Alex Chen',
        xp: 12500,
        streak: 45,
        rank: 1,
        avatar: 'AC',
        color: AppColors.primary,
      ),
      LeaderboardUser(
        name: 'Sarah Johnson',
        xp: 11200,
        streak: 38,
        rank: 2,
        avatar: 'SJ',
        color: AppColors.secondary,
      ),
      LeaderboardUser(
        name: 'Mike Rodriguez',
        xp: 9800,
        streak: 32,
        rank: 3,
        avatar: 'MR',
        color: AppColors.accent,
      ),
      LeaderboardUser(
        name: userName,
        xp: userXP,
        streak: userStreak,
        rank: 4,
        avatar: userName.substring(0, 2).toUpperCase(),
        color: Colors.blue,
        isCurrentUser: true,
      ),
      LeaderboardUser(
        name: 'Emma Wilson',
        xp: 7200,
        streak: 25,
        rank: 5,
        avatar: 'EW',
        color: Colors.purple,
      ),
      LeaderboardUser(
        name: 'David Kim',
        xp: 6800,
        streak: 22,
        rank: 6,
        avatar: 'DK',
        color: Colors.teal,
      ),
      LeaderboardUser(
        name: 'Lisa Anderson',
        xp: 5400,
        streak: 18,
        rank: 7,
        avatar: 'LA',
        color: Colors.orange,
      ),
      LeaderboardUser(
        name: 'James Brown',
        xp: 4900,
        streak: 15,
        rank: 8,
        avatar: 'JB',
        color: Colors.pink,
      ),
    ];
    
    // Sort by XP
    _leaderboard.sort((a, b) => b.xp.compareTo(a.xp));
    
    // Update ranks
    for (int i = 0; i < _leaderboard.length; i++) {
      _leaderboard[i] = LeaderboardUser(
        name: _leaderboard[i].name,
        xp: _leaderboard[i].xp,
        streak: _leaderboard[i].streak,
        rank: i + 1,
        avatar: _leaderboard[i].avatar,
        color: _leaderboard[i].color,
        isCurrentUser: _leaderboard[i].isCurrentUser,
      );
      
      // Rank updated in the loop above
    }
    
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
                        'Leaderboard',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadLeaderboard,
                    ),
                  ],
                ),
              ),

              // Period selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedPeriod = period);
                            _loadLeaderboard();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppGradients.primaryGradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              period,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Top 3 Podium
              if (!_isLoading && _leaderboard.length >= 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd place
                      Expanded(
                        child: _buildPodiumUser(_leaderboard[1], 2),
                      ),
                      const SizedBox(width: 8),
                      // 1st place
                      Expanded(
                        child: _buildPodiumUser(_leaderboard[0], 1),
                      ),
                      const SizedBox(width: 8),
                      // 3rd place
                      Expanded(
                        child: _buildPodiumUser(_leaderboard[2], 3),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                ),

              const SizedBox(height: 32),

              // Leaderboard list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _leaderboard.length,
                        itemBuilder: (context, index) {
                          final user = _leaderboard[index];
                          return _buildLeaderboardItem(user, index)
                              .animate()
                              .fadeIn(
                                duration: 300.ms,
                                delay: (index * 50).ms,
                              )
                              .slideX(begin: -0.1);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumUser(LeaderboardUser user, int position) {
    final heights = [120.0, 140.0, 100.0];
    final medals = [Icons.emoji_events, Icons.workspace_premium, Icons.military_tech];
    final medalColors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.brown.shade300,
    ];

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                user.color,
                user.color.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: user.color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.avatar,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          medals[position - 1],
          color: medalColors[position - 1],
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${user.xp} XP',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: heights[position - 1],
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                user.color.withOpacity(0.3),
                user.color.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '#$position',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user, int index) {
    final isTopThree = user.rank <= 3;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Rank
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? AppGradients.primaryGradient
                  : null,
              color: isTopThree
                  ? null
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: user.isCurrentUser
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '#${user.rank}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  user.color,
                  user.color.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatar,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: user.isCurrentUser
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (user.isCurrentUser)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.xp} XP',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.streak} days',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final String name;
  final int xp;
  final int streak;
  final int rank;
  final String avatar;
  final Color color;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.name,
    required this.xp,
    required this.streak,
    required this.rank,
    required this.avatar,
    required this.color,
    this.isCurrentUser = false,
  });
}

