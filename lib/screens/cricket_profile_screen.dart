import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_colors.dart';
import '../services/supabase_client.dart';

class CricketProfileScreen extends StatelessWidget {
  const CricketProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final name = (user?.userMetadata?['full_name'] as String?) ?? '-';
    final city = (user?.userMetadata?['city'] as String?) ?? '-';
    final since = (user?.userMetadata?['since'] as String?) ?? '-';
    final meta = user?.userMetadata ?? {};

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Cricket profile'),
        backgroundColor: AppColors.primaryElectric,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildHeaderCard(name, city, since),
          const SizedBox(height: 12),
          _buildProfileSection(context, meta),
          const SizedBox(height: 24),
          _buildSettingsSection(context),
          const SizedBox(height: 24),
          _buildFooterBanner(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String name, String city, String since) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundCardAlt,
                  border: Border.all(
                    color: AppColors.profileRing,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 36,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          since,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Go PRO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ProfileStatsItem(label: 'QR code', value: Icons.qr_code_2),
              _ProfileStatsNumber(label: 'Followers', value: '0'),
              _ProfileStatsNumber(label: 'Profile views', value: '22'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, Map<String, dynamic> meta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhitePurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildProfileRow('Mobile number', _metaString(meta, 'phone', '-')),
          _buildProfileRow('Gender', _metaString(meta, 'gender', '-')),
          _buildProfileRow('Playing role', _metaString(meta, 'playing_role', '-')),
          _buildProfileRow('Batting style', _metaString(meta, 'batting_style', '-')),
          _buildProfileRow('Bowling style', _metaString(meta, 'bowling_style', '-')),
          _buildProfileRow('Date of birth', _metaString(meta, 'dob', '-')),
          _buildProfileRow('Email', _metaString(meta, 'email', '-')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 75,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryElectric,
                                AppColors.primaryElectricLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const Expanded(flex: 25, child: SizedBox()),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '75%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Complete profile',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _metaString(Map<String, dynamic> meta, String key, String fallback) {
    final raw = meta[key];
    if (raw is String && raw.trim().isNotEmpty && raw.trim() != '-') {
      return raw.trim();
    }
    return fallback;
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Find Cricketers',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Edit notification preferences',
            onTap: () => Navigator.pushNamed(context, '/notification-settings'),
          ),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Change language',
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await supabase.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        await supabase.auth.updateUser(
                          UserAttributes(data: {
                            'full_name': '',
                            'city': '',
                            'since': '',
                            'phone': '',
                            'gender': '',
                            'playing_role': '',
                            'batting_style': '',
                            'bowling_style': '',
                            'dob': '',
                            'email': '',
                          }),
                        );
                      }
                      await supabase.auth.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile data cleared. Please login again.')),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/auth',
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Clear data'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = [
      'English',
      'Hindi',
      'Kannada',
      'Malayalam',
      'Tamil',
      'Telugu',
      'Punjabi',
      'Marathi',
      'Urdu',
      'Bangla',
    ];

    String selected = languages.first;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Change language',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: languages.map((lang) {
                        final isSelected = selected == lang;
                        return GestureDetector(
                          onTap: () => setState(() => selected = lang),
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryTeal : AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryTeal : AppColors.divider,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lang,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // For now just close; no persistence.
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFooterBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0FBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'To keep your stats safe, add your Email now.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileStatsItem extends StatelessWidget {
  final String label;
  final IconData value;

  const _ProfileStatsItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(value, size: 22, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatsNumber extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatsNumber({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

