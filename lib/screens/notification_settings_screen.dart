import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications settings'),
        backgroundColor: AppColors.primaryElectric,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildMainItem(
                  context: context,
                  icon: Icons.emoji_events_outlined,
                  title: 'Tournaments',
                  subtitle:
                      'Officials Needed, Tournaments by same organiser, Tournaments at Familiar Grounds, News, Tournaments in Your City',
                  route: '/notifications-tournaments',
                ),
                _buildMainItem(
                  context: context,
                  icon: Icons.person_add_alt_outlined,
                  title: 'Connections',
                  subtitle: 'Followed, Team Follow',
                  route: '/notifications-connections',
                ),
                _buildMainItem(
                  context: context,
                  icon: Icons.tune,
                  title: 'Cricket Feed',
                  subtitle:
                      'CricHeroes Promotions, CricHeroes Announcements, Videos, Reply Notification',
                  route: '/notifications-feed',
                ),
                _buildMainItem(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  title: 'DM (Messages)',
                  subtitle: 'Direct Messages',
                  route: '/notifications-dm',
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Push notifications enabled (demo only).'),
                      ),
                    );
                  },
                  child: const Text(
                    'Enable push notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryTeal),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}

class TournamentNotificationsScreen extends StatefulWidget {
  const TournamentNotificationsScreen({super.key});

  @override
  State<TournamentNotificationsScreen> createState() =>
      _TournamentNotificationsScreenState();
}

class _TournamentNotificationsScreenState
    extends State<TournamentNotificationsScreen> {
  bool news = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tournaments - Notifications'),
        backgroundColor: AppColors.primaryElectric,
      ),
      body: ListTile(
        title: const Text(
          'News',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
        ),
        subtitle: const Text(
          'Get notified about your Tournament News when it is posted.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(
          value: news,
          activeColor: AppColors.primaryTeal,
          onChanged: (value) {
            setState(() => news = value);
          },
        ),
      ),
    );
  }
}

class ConnectionsNotificationsScreen extends StatefulWidget {
  const ConnectionsNotificationsScreen({super.key});

  @override
  State<ConnectionsNotificationsScreen> createState() =>
      _ConnectionsNotificationsScreenState();
}

class _ConnectionsNotificationsScreenState
    extends State<ConnectionsNotificationsScreen> {
  bool followed = true;
  bool teamFollow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Connections - Notifications'),
        backgroundColor: AppColors.primaryElectric,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Followed'),
            subtitle: const Text(
              'Get notified when someone starts following you on Innings.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: followed,
            activeColor: AppColors.primaryTeal,
            onChanged: (value) => setState(() => followed = value),
          ),
          SwitchListTile(
            title: const Text('Team Follow'),
            subtitle: const Text(
              'Get summary of scores of teams you are following after match ends.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: teamFollow,
            activeColor: AppColors.primaryTeal,
            onChanged: (value) => setState(() => teamFollow = value),
          ),
        ],
      ),
    );
  }
}

class FeedNotificationsScreen extends StatefulWidget {
  const FeedNotificationsScreen({super.key});

  @override
  State<FeedNotificationsScreen> createState() =>
      _FeedNotificationsScreenState();
}

class _FeedNotificationsScreenState extends State<FeedNotificationsScreen> {
  bool promotions = true;
  bool announcements = true;
  bool videos = false;
  bool replyNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Cricket Feed - Notifications'),
        backgroundColor: AppColors.primaryElectric,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Innings Promotions'),
            subtitle: const Text(
              'Get notified when an interesting tournament is coming up in your region and all such goodies from Innings.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: promotions,
            activeColor: AppColors.primaryTeal,
            onChanged: (value) => setState(() => promotions = value),
          ),
          SwitchListTile(
            title: const Text('Innings Announcements'),
            subtitle: const Text(
              'Get notified about new features and exciting updates from Innings.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: announcements,
            activeColor: AppColors.primaryTeal,
            onChanged: (value) => setState(() => announcements = value),
          ),
          SwitchListTile(
            title: const Text('Videos'),
            subtitle: const Text(
              'Get notified when new cricket video is posted in Innings feed.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: videos,
            activeColor: AppColors.primaryTeal,
            onChanged: (value) => setState(() => videos = value),
          ),
          SwitchListTile(
            title: const Text('Reply Notification'),
            subtitle: const Text(
              'Get notified when anyone left reply on your comment in Innings feed.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: replyNotification,
            activeColor: AppColors.primaryTeal,
            onChanged: (value) => setState(() => replyNotification = value),
          ),
        ],
      ),
    );
  }
}

class DmNotificationsScreen extends StatefulWidget {
  const DmNotificationsScreen({super.key});

  @override
  State<DmNotificationsScreen> createState() => _DmNotificationsScreenState();
}

class _DmNotificationsScreenState extends State<DmNotificationsScreen> {
  bool directMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('DM (Messages) - Notifications'),
        backgroundColor: AppColors.primaryElectric,
      ),
      body: SwitchListTile(
        title: const Text('Direct Messages'),
        subtitle: const Text(
          'Get notified when someone sends you a message.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        value: directMessages,
        activeColor: AppColors.primaryTeal,
        onChanged: (value) => setState(() => directMessages = value),
      ),
    );
  }
}

