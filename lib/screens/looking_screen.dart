import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LookingScreen extends StatefulWidget {
  final String? searchQuery;
  const LookingScreen({super.key, this.searchQuery});

  @override
  State<LookingScreen> createState() => _LookingScreenState();
}

class _LookingScreenState extends State<LookingScreen> {
  String get _effectiveQuery => widget.searchQuery ?? '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. CricHeroes-style: Discover teams, opponents, players, umpires, grounds
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Looking for',
                  style: TextStyle(fontSize: 16, color: Color(0xFF444444)),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Scorer?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryElectric),
                ),
                const Spacer(),
                _buildActionChip(Icons.add_circle_outline, 'Post'),
                const SizedBox(width: 8),
                _buildActionChip(Icons.account_circle_outlined, 'You'),
              ],
            ),
          ),
          // Book scorers, umpires, commentators, grounds (CricHeroes ecosystem)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryElectric.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryElectric.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sports_cricket_rounded, color: AppColors.primaryElectric, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book Scorers, Umpires, Commentators & Grounds',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Cricket ecosystem – find and book for your matches',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryElectric),
                  ],
                ),
              ),
            ),
          ),
          // 2. Filter Strips (discovery: teams, opponents, players, umpires, grounds)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Location', isActive: true, showBorder: false),
                const VerticalDivider(width: 24, thickness: 1, indent: 8, endIndent: 8),
                _buildFilterChip('Scorer'),
                _buildFilterChip('Opponent'),
                _buildFilterChip('Team to Join'),
                _buildFilterChip('Players'),
                _buildFilterChip('Umpires'),
                _buildFilterChip('Grounds'),
                _buildFilterChip('Pitch'),
              ],
            ),
          ),
          const Divider(height: 1),

          // 3. Main List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildLookingCard(
                  name: "D Rajesh's team (Fire Storm)",
                  finding: "Bowler (None)",
                  details: ["Open ground", "Bowler (None)"],
                  timestamp: "34 seconds ago",
                  isPro: true,
                ),
                _buildLookingCard(
                  name: "Mahesh's team (Fire Blasters)",
                  finding: "opponent to play a Match",
                  details: ["Wed, Feb 04 2026 | 07:00 AM", "Open ground"],
                  timestamp: "13 minutes ago",
                  iconType: "VS",
                  isPro: true,
                ),
                _buildLookingCard(
                  name: "Chiranjeet's team (Divine Kings)",
                  finding: "All-rounder (Right-arm Off Break)",
                  details: ["Thu, Feb 05 2026", "All-rounder (Right-arm Off Break)"],
                  timestamp: "14 minutes ago",
                  isPro: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryElectric,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false, bool showBorder = true}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.transparent : Colors.white,
        border: showBorder ? Border.all(color: AppColors.primaryElectric.withOpacity(0.5)) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryElectric : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            decoration: isActive ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLookingCard({
    required String name,
    required String finding,
    required List<String> details,
    required String timestamp,
    bool isPro = false,
    String? iconType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  if (iconType == "VS")
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Text('VS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Color(0xFF444444), fontSize: 13, height: 1.4),
                              children: [
                                TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const TextSpan(text: ' is looking for a '),
                                TextSpan(text: finding, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const TextSpan(text: ' to join his team.'),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.person_pin, color: Colors.grey, size: 36),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Bullets
                    ...details.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(detail, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Footer
          Row(
            children: [
              Text(timestamp, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(width: 8),
              const Icon(Icons.circle, size: 12, color: Colors.red),
              const Spacer(),
              const Icon(Icons.location_on_outlined, color: AppColors.primaryElectric, size: 16),
              const SizedBox(width: 4),
              const Text('-- KM', style: TextStyle(color: AppColors.primaryElectric, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline, color: AppColors.primaryElectric, size: 16),
              const SizedBox(width: 4),
              const Text('Contact', style: TextStyle(color: AppColors.primaryElectric, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
