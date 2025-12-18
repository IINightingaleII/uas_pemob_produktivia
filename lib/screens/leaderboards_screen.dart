import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../widgets/home_drawer.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  State<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();

  // State for current user data
  LeaderboardUser? _currentUserLeaderboardData;
  bool _isLoading = true;

  // Mock Data for other users
  final List<LeaderboardUser> _otherUsers = [
    LeaderboardUser(
      name: 'Jennie Doe Wolf',
      points: 10000,
      rank: 1,
      imageUrl: 'https://i.pravatar.cc/150?u=1',
      isCurrentUser: false,
    ),
    LeaderboardUser(
      name: 'Meghan Jessica',
      points: 8000,
      rank: 2,
      imageUrl: 'https://i.pravatar.cc/150?u=2',
      isCurrentUser: false,
    ),
    LeaderboardUser(
      name: 'Alex Turner',
      points: 5000,
      rank: 3,
      imageUrl: 'https://i.pravatar.cc/150?u=3',
      isCurrentUser: false,
    ),
    LeaderboardUser(
      name: 'Chintiya Kendrick',
      points: 4800,
      rank: 4,
      imageUrl: 'https://i.pravatar.cc/150?u=4',
      isCurrentUser: false,
    ),
    LeaderboardUser(
      name: 'Sonia Laura',
      points: 4600,
      rank: 5,
      imageUrl: 'https://i.pravatar.cc/150?u=5',
      isCurrentUser: false,
    ),
    LeaderboardUser(
      name: 'Alan David',
      points: 4460,
      rank: 6,
      imageUrl: 'https://i.pravatar.cc/150?u=6',
      isCurrentUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userModel = await _authService.getCurrentUserData();

      setState(() {
        _currentUserLeaderboardData = LeaderboardUser(
          name: userModel?.displayName ?? 'You',
          points: 1032, // Mock points as backend doesn't support it yet
          rank: 112, // Mock rank
          imageUrl:
              userModel?.profileImageUrl ?? 'https://i.pravatar.cc/150?u=99',
          isCurrentUser: true,
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _currentUserLeaderboardData = LeaderboardUser(
          name: 'You',
          points: 1032,
          rank: 112,
          imageUrl: 'https://i.pravatar.cc/150?u=99',
          isCurrentUser: true,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine current user (if loaded) with others for processing if needed,
    // but here we keep them separate as per UI design (Top 3 vs Rest vs You sticky)

    // Sort top 3 for display: 2, 1, 3
    final top3 = _otherUsers.where((u) => u.rank <= 3).toList();
    final displayTop3 = [
      top3.firstWhere((u) => u.rank == 2, orElse: () => top3[0]),
      top3.firstWhere((u) => u.rank == 1, orElse: () => top3[0]),
      top3.firstWhere((u) => u.rank == 3, orElse: () => top3[0]),
    ];

    final restUsers = _otherUsers.where((u) => u.rank > 3).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: HomeDrawer(currentUser: _authService.currentUser),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.paddingHorizontal(context),
                vertical: Responsive.spacing(context, 12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        if (_scaffoldKey.currentState?.hasDrawer ?? false) {
                          _scaffoldKey.currentState?.openDrawer();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset(
                        'assets/icons2/Nav.png',
                        width: Responsive.iconSize(context, 24),
                        height: Responsive.iconSize(context, 24),
                        color: const Color(0xFF9183DE),
                        errorBuilder: (c, o, s) =>
                            const Icon(Icons.menu, color: Color(0xFF9183DE)),
                      ),
                    ),
                  ),
                  Text(
                    'Leaderboards',
                    style: GoogleFonts.jost(
                      fontSize: Responsive.fontSize(context, 20),
                      color: const Color(0xFF9183DE),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Top 3 Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.paddingHorizontal(context),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: displayTop3
                              .map((user) => _buildTop3Item(context, user))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // List Section Container
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.paddingHorizontal(context),
                        ),
                        child: Column(
                          children: [
                            // "You" Item (Sticky-like look)
                            if (_currentUserLeaderboardData != null)
                              _buildListItem(
                                context,
                                _currentUserLeaderboardData!,
                              ),
                            const SizedBox(height: 12),
                            // Rest of users
                            ...restUsers.map(
                              (user) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildListItem(context, user),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop3Item(BuildContext context, LeaderboardUser user) {
    final isFirst = user.rank == 1;
    final double avatarSize = isFirst ? 80 : 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) ...[
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFEADB5E),
            size: 30,
          ), // Crown
          const SizedBox(height: 4),
        ],
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isFirst
                    ? Border.all(color: const Color(0xFF9183DE), width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${user.rank}',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name.split(' ').first +
              (user.name.split(' ').length > 1 ? '...' : ''),
          style: GoogleFonts.jost(
            fontWeight: FontWeight.w600,
            fontSize: isFirst ? 16 : 14,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user.points} pts',
          style: GoogleFonts.jost(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, LeaderboardUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left indicator for current user
          if (user.isCurrentUser)
            Container(
              width: 4,
              height: 30,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.purple.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user.imageUrl),
            backgroundColor: Colors.grey.shade200,
            onBackgroundImageError: (_, __) {},
            child: user.imageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: user.isCurrentUser
                        ? const Color(0xFF2E2C4F)
                        : Colors.black87,
                  ),
                ),
                Text(
                  '${user.points}',
                  style: GoogleFonts.jost(
                    fontSize: 14,
                    color: const Color(0xFF9183DE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 20,
                color: const Color(0xFF9183DE).withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '#${user.rank}',
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF9183DE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final String name;
  final int points;
  final int rank;
  final String imageUrl;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.name,
    required this.points,
    required this.rank,
    required this.imageUrl,
    required this.isCurrentUser,
  });
}
