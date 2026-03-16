import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}










