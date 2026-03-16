import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/supabase_client.dart';

class InningsDrawer extends StatelessWidget {
  /// When set, tapping "My Cricket" closes the drawer and switches to My Cricket tab.
  final VoidCallback? onMyCricketTap;

  const InningsDrawer({super.key, this.onMyCricketTap});

  double _calculateProfileCompletion(Map<String, dynamic> meta) {
    final fields = [
      meta['phone'],
      meta['gender'],
      meta['playing_role'],
      meta['batting_style'],
      meta['bowling_style'],
      meta['dob'],
      meta['email'],
    ];

    int filled = 0;
    for (final value in fields) {
      if (value is String && value.trim().isNotEmpty && value.trim() != '-') {
        filled++;
      }
    }
    if (fields.isEmpty) return 0.0;
    return filled / fields.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User Name';
    final userPhone = user?.userMetadata?['phone'] ?? 'Phone Number';

    final userMeta = user?.userMetadata ?? {};
    final completion = _calculateProfileCompletion(userMeta);
    final completionPercent = (completion * 100).round();

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          // 1. Premium Header (Gradient + dynamic completion)
          InkWell(
            onTap: () {
              if (user == null) {
                Navigator.pushNamed(context, '/auth');
              } else {
                Navigator.pushNamed(context, '/cricket-profile');
              }
            },
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryPurpleDark, AppColors.primaryElectric],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile Photo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userPhone,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: const Text(
                                'Free User',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress Bar (dynamic based on profile completion)
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: completion.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryTeal, AppColors.accentGlow],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$completionPercent%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Drawer Items List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.add_box_outlined,
                  title: 'Add a Tournament/Series',
                  badge: 'Free',
                  badgeColor: Colors.grey[600]!,
                  onTap: () => _handleLoginRequiredAction(context, '/add-tournament'),
                ),
                _buildDrawerItem(
                  icon: Icons.sports_cricket_outlined,
                  title: 'Start A Match',
                  badge: 'Free',
                  badgeColor: Colors.grey[600]!,
                  onTap: () => _handleLoginRequiredAction(context, '/select-playing-teams'),
                ),
                _buildDrawerItem(
                  icon: Icons.videocam_outlined,
                  title: 'Go Live',
                  onTap: () => Navigator.pushNamed(context, '/live-stream-plan'),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                _buildDrawerItem(
                  icon: Icons.sports_cricket,
                  title: 'My Cricket',
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    if (onMyCricketTap != null) {
                      onMyCricketTap!();
                    } else {
                      Navigator.pushNamed(context, '/my-cricket');
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'My Performance',
                  onTap: () => Navigator.pushNamed(context, '/player-performance'),
                ),
                _buildDrawerItem(
                  icon: Icons.leaderboard_outlined,
                  title: 'Player Leaderboard',
                  onTap: () => Navigator.pushNamed(context, '/player-leaderboard'),
                ),
                _buildDrawerItem(
                  icon: Icons.groups_outlined,
                  title: 'Team Leaderboard',
                  onTap: () => Navigator.pushNamed(context, '/team-leaderboard'),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                _buildDrawerItem(
                  icon: Icons.phone_outlined,
                  title: 'Contact',
                  onTap: () => Navigator.pushNamed(context, '/contact'),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                _buildDrawerItem(
                  icon: Icons.share_outlined,
                  title: 'Share the app',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing Innings App...')),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.star_border_rounded,
                  title: 'Rate us',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your rating!')),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.vpn_key_outlined,
                  title: 'App code',
                  onTap: () => Navigator.pushNamed(context, '/coming-soon', arguments: {'title': 'App Code'}),
                ),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Icon(Icons.more_horiz, color: Colors.grey[600]),
                    title: const Text(
                      'More',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    children: [
                      _buildDrawerItem(
                        title: 'Terms & Conditions', 
                        paddingLeft: 72,
                        onTap: () => Navigator.pushNamed(context, '/coming-soon', arguments: {'title': 'Terms & Conditions'}),
                      ),
                      _buildDrawerItem(
                        title: 'Privacy Policy', 
                        paddingLeft: 72,
                        onTap: () => Navigator.pushNamed(context, '/coming-soon', arguments: {'title': 'Privacy Policy'}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLoginRequiredAction(BuildContext context, String route) {
    final user = supabase.auth.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to login to start a match and manage scores.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/auth');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryElectric,
                foregroundColor: Colors.white,
              ),
              child: const Text('LOGIN'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  Widget _buildDrawerItem({
    IconData? icon,
    required String title,
    String? badge,
    Color? badgeColor,
    Widget? trailing,
    double paddingLeft = 16,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: paddingLeft, right: 16),
      leading: icon != null ? Icon(icon, color: Colors.grey[600], size: 24) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF444444),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                border: Border.all(color: badgeColor ?? Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor ?? Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
