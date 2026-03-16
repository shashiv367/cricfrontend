import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CommunityCategoryScreen extends StatelessWidget {
  final String categoryName;
  final String categoryId;

  const CommunityCategoryScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  static const String _location = 'Hyderabad (Telangana)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                Material(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Nearby ', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    '$_location (change)',
                    style: const TextStyle(fontSize: 13, color: AppColors.primaryTeal, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.swap_vert, size: 22, color: AppColors.textSecondary),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildVenueCard('Battlefield Box Cricket Gro...', '3 Review(s)', '2', '5'),
                _buildVenueCard('Ethinya Sports', null, null, null),
                _buildVenueCard('PLAY LIKE PRO (Indoor Cri...', '1 Review(s)', '5', '5'),
                _buildVenueCard('SYP Cricket Nets', '7 Review(s)', '3.7', '5'),
                _buildVenueCard('THE BOX @ YMCA', '4 Review(s)', '4', '5'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(String title, String? reviewText, String? rating, String? outOf) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryElectric.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.image_outlined, size: 36, color: AppColors.primaryElectric.withOpacity(0.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(_location, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                if (reviewText != null && rating != null && outOf != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$rating/$outOf',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(reviewText, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
