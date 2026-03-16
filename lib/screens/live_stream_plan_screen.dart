import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'community_category_screen.dart';

class LiveStreamPlanScreen extends StatelessWidget {
  const LiveStreamPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'How do you plan to live stream?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStreamOptionCard(
                  context,
                  title: 'via Mobile Phone',
                  icon: Icons.smartphone_rounded,
                  subtitle: 'Use your phone to go live',
                ),
                const SizedBox(height: 16),
                _buildStreamOptionCard(
                  context,
                  title: 'via Professional Camera',
                  icon: Icons.videocam_rounded,
                  subtitle: 'Broadcast with pro equipment',
                ),
                const SizedBox(height: 16),
                _buildStreamOptionCard(
                  context,
                  title: 'via CAPTURE Device',
                  icon: Icons.camera_alt_rounded,
                  subtitle: 'Dedicated streaming device',
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildStreamOptionCard(BuildContext context, {required String title, required IconData icon, required String subtitle}) {
    return Material(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryElectric.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, size: 56, color: AppColors.primaryElectric.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Looking for live streamers?',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          Material(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CommunityCategoryScreen(
                      categoryName: 'Streamers',
                      categoryId: 'Streamers',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('Find here', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
