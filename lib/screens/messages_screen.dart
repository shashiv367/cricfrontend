import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {'name': 'D Rajesh', 'msg': 'Are you coming for the match today?', 'time': '10:30 AM', 'unread': true},
      {'name': 'Fire Blasters Group', 'msg': 'Mahesh: Let\'s win this!', 'time': '9:15 AM', 'unread': false},
      {'name': 'Cricket Academy', 'msg': 'New training schedule added.', 'time': 'Yesterday', 'unread': false},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryElectric.withOpacity(0.1),
              child: Text(chat['name'].toString()[0], style: const TextStyle(color: AppColors.primaryElectric, fontWeight: FontWeight.bold)),
            ),
            title: Text(chat['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat['msg'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'].toString(), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                if (chat['unread'] as bool)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.primaryElectric, shape: BoxShape.circle),
                  ),
              ],
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}










