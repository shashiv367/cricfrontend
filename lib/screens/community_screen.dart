import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'community_category_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static const String _defaultLocation = 'Hyderabad (Telangana)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  children: [
                    const TextSpan(text: 'Cricket community in '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          _defaultLocation,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildCategoryCard(context, Icons.scoreboard_rounded, 'Scorers', 'Scorers'),
                  _buildCategoryCard(context, Icons.sports_rounded, 'Umpires', 'Umpires'),
                  _buildCategoryCard(context, Icons.mic_rounded, 'Commentators', 'Commentators'),
                  _buildCategoryCard(context, Icons.videocam_rounded, 'Streamers', 'Streamers'),
                  _buildCategoryCard(context, Icons.person_rounded, 'Organisers', 'Organisers'),
                  _buildCategoryCard(context, Icons.school_rounded, 'Academies', 'Academies'),
                  _buildCategoryCard(context, Icons.place_rounded, 'Grounds', 'Grounds'),
                  _buildCategoryCard(context, Icons.store_rounded, 'Shops', 'Shops'),
                  _buildCategoryCard(context, Icons.fitness_center_rounded, 'Physio and Fitness Trainer', 'Physio and Fitness Trainer'),
                  _buildCategoryCard(context, Icons.sports_cricket_rounded, 'Personal Coaching', 'Personal Coaching'),
                  _buildCategoryCard(context, Icons.grid_3x3_rounded, 'Box Cricket & Nets', 'Box Cricket & Nets'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String label, String categoryId) {
    return Material(
      color: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      shadowColor: AppColors.shadowColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityCategoryScreen(
                categoryName: label,
                categoryId: categoryId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.textPrimary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
