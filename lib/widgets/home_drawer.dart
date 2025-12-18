import 'package:flutter/material.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/focus_mode_screen.dart';
import '../screens/leaderboards_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';

class HomeDrawer extends StatelessWidget {
  final dynamic currentUser;

  const HomeDrawer({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Header dengan back arrow
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile picture
                FutureBuilder(
                  future: AuthService().getCurrentUserData(),
                  builder: (context, snapshot) {
                    String? profileImageUrl;
                    if (snapshot.hasData && snapshot.data != null) {
                      profileImageUrl = snapshot.data!.profileImageUrl;
                    }
                    
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Display name
                Text(
                  'Hello ${currentUser?.displayName ?? 'Produktivia'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  currentUser?.email ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: 'assets/icons2/edit.png',
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: 'assets/icons2/home-dailytask.png',
                  title: 'Tasks',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: 'assets/icons2/Focus-mode-star.png',
                  title: 'Focus Mode',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FocusModeScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: 'assets/icons2/Leaderboards.png',
                  title: 'Leaderboards',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(
        icon,
        width: 24,
        height: 24,
        color: Colors.grey,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

