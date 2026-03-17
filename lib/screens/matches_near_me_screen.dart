import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MatchesNearMeScreen extends StatefulWidget {
  const MatchesNearMeScreen({super.key});

  @override
  State<MatchesNearMeScreen> createState() => _MatchesNearMeScreenState();
}

class _MatchesNearMeScreenState extends State<MatchesNearMeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _tabController.index == 0 ? 'Matches near me' : 'Tournaments near me',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.backgroundWhite,
            child: TabBar(
              controller: _tabController,
              onTap: (i) => setState(() {}),
              indicatorColor: AppColors.primaryElectric,
              indicatorWeight: 3,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: const [
                Tab(text: 'Matches'),
                Tab(text: 'Tournaments'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLocationPrompt(
                  title: 'Find matches near your location',
                  listLabel: 'LIVE',
                ),
                _buildLocationPrompt(
                  title: 'Find tournaments near your location',
                  listLabel: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPrompt({required String title, String? listLabel}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildEmptyStateIllustration(listLabel: listLabel),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 28),
          Material(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: const Text('Use current location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Select location manually',
              style: TextStyle(color: AppColors.primaryTeal, fontSize: 15, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyStateIllustration({String? listLabel}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listLabel != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(listLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.normal)),
                  ),
                ),
              if (listLabel != null) const SizedBox(height: 12),
              _placeholderLine(180),
              const SizedBox(height: 8),
              _placeholderLine(120),
              const SizedBox(height: 8),
              _placeholderLine(150),
              const SizedBox(height: 8),
              _placeholderLine(100),
            ],
          ),
        ),
        Positioned(
          left: 40,
          bottom: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, size: 28, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Icon(Icons.place_outlined, size: 28, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Icon(Icons.arrow_upward_rounded, size: 24, color: AppColors.primaryTeal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholderLine(double width) {
    return SizedBox(
      width: width,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
