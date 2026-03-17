import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TeamSquadDetailScreen extends StatelessWidget {
  const TeamSquadDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String teamName = args['teamName'] ?? 'Team Squad';

    return Column(
      children: [
        _buildAppBar(context, teamName),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildSectionHeader('BATTERS'),
              _buildPlayerItem('Tim David', true),
              _buildPlayerItem('Jake Weatherald', true),
              _buildPlayerItem('Macalister Wright', false),
              _buildPlayerItem('Tim Ward', false),
              
              _buildSectionHeader('ALL ROUNDERS'),
              _buildPlayerItem('Mitchell Owen', true),
              _buildPlayerItem('Beau Webster', true),
              _buildPlayerItem('Rehan Ahmed', true),
              _buildPlayerItem('Nikhil Chaudhary', false),

              _buildSectionHeader('WICKET KEEPERS'),
              _buildPlayerItem('Ben McDermott', true),
              _buildPlayerItem('Matthew Wade', true),

              _buildSectionHeader('BOWLERS'),
              _buildPlayerItem('Iain Carlisle', false),
              _buildPlayerItem('Nathan Ellis', true),
              _buildPlayerItem('Rishad Hossain', true),
              _buildPlayerItem('Chris Jordan', true),
              _buildPlayerItem('Riley Meredith', true),
              _buildPlayerItem('Billy Stanlake', true),
              
              const SizedBox(height: 100), // Bottom spacing for FAB or Nav
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryElectric, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white.withOpacity(0.5),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildPlayerItem(String name, bool hasImage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: hasImage 
            ? null // In a real app, use Image.network
            : const Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: AppColors.textPrimary)),
      ),
    );
  }
}

