import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'New Match Invitation',
        'subtitle': 'D Rajesh invited you to join Fire Storm.',
        'time': '2m ago',
        'icon': Icons.sports_cricket,
        'isUnread': true,
      },
      {
        'title': 'Tournament Update',
        'subtitle': 'Innings Summer Cup schedule is out!',
        'time': '1h ago',
        'icon': Icons.emoji_events,
        'isUnread': true,
      },
      {
        'title': 'Profile Viewed',
        'subtitle': '3 scouts viewed your profile today.',
        'time': '5h ago',
        'icon': Icons.visibility,
        'isUnread': false,
      },
      {
        'title': 'Score Updated',
        'subtitle': 'Your last match score has been verified.',
        'time': 'Yesterday',
        'icon': Icons.check_circle,
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.normal)),
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            color: item['isUnread'] as bool ? AppColors.primaryElectric.withOpacity(0.05) : Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryElectric.withOpacity(0.1),
                child: Icon(item['icon'] as IconData, color: AppColors.primaryElectric, size: 20),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontWeight: item['isUnread'] as bool ? FontWeight.normal : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(item['subtitle'] as String, style: const TextStyle(fontSize: 13)),
              trailing: Text(
                item['time'] as String,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
