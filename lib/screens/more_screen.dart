import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'coming_soon_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Transparent Header (splatter shows through)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, left: 24, bottom: 20, right: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryElectric, Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INNINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                'Elite Coordination Platform',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        
        // CricHeroes-style: Store, Ranking, Settings, Invite, Tournaments at top
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 12),
              _buildMoreItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Store',
                subtitle: 'Cricket products & services',
                onTap: () => Navigator.pushNamed(context, '/store'),
              ),
              _buildMoreItem(
                icon: Icons.emoji_events_outlined,
                title: 'Ranking',
                onTap: () => Navigator.pushNamed(context, '/ranking'),
              ),
              _buildMoreItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Settings'))),
              ),
              _buildMoreItem(
                icon: Icons.person_add_outlined,
                title: 'Invite',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Invite Friends'))),
              ),
              _buildMoreItem(
                icon: Icons.emoji_events_rounded,
                title: 'Tournaments',
                subtitle: 'Create & manage tournaments',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Tournaments'))),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text('Account & Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
              _buildMoreItem(
                icon: Icons.account_circle_outlined,
                title: 'My Account',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin Panel',
                onTap: () => Navigator.pushNamed(context, '/admin'),
              ),
              _buildMoreItem(
                icon: Icons.groups_outlined,
                title: 'Player Roster',
                onTap: () => Navigator.pushNamed(context, '/players'),
              ),
              _buildMoreItem(
                icon: Icons.play_circle_outline,
                title: 'Buzz Shorts',
                suffixIcon: const Text('⚡', style: TextStyle(fontSize: 16)),
                onTap: () {},
              ),
              const SizedBox(height: 12), // Section divider
              _buildMoreItem(
                icon: Icons.emoji_events_outlined,
                title: 'Browse Series',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.groups_outlined,
                title: 'Browse Team',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.person_outline,
                title: 'Browse Player',
                onTap: () {},
              ),
              const SizedBox(height: 12), // Section divider
              _buildMoreItem(
                icon: Icons.calendar_today_outlined,
                title: 'Schedule',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.history_outlined,
                title: 'Archives',
                onTap: () {},
              ),
              const SizedBox(height: 12), // Section divider
              _buildMoreItem(
                icon: Icons.trending_up,
                title: 'ICC Rankings - Men',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.trending_up,
                title: 'ICC Rankings - Women',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.bubble_chart_outlined,
                title: 'Records',
                onTap: () {},
              ),
              const SizedBox(height: 12), // Section divider
              _buildMoreItem(
                icon: Icons.stadium_outlined,
                title: 'ICC World Test Championship',
                onTap: () {},
              ),
              _buildMoreItem(
                icon: Icons.image_outlined,
                title: 'Photos',
                onTap: () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? suffixIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: Icon(
              icon,
              color: AppColors.primaryElectric,
              size: 24,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: subtitle != null
                ? Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                : null,
            trailing: suffixIcon ?? const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          ),
          const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6)),
        ],
      ),
    );
  }
}
