import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MatchOfficialsScreen extends StatelessWidget {
  const MatchOfficialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: const Text('Match officials'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Select umpires'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _officialSlot(
                        context,
                        label: '1st',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire'),
                      ),
                      _officialSlot(
                        context,
                        label: '2nd',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire'),
                      ),
                      _officialSlot(
                        context,
                        label: '3rd',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire'),
                      ),
                      _officialSlot(
                        context,
                        label: '4th',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Select scorers'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _officialSlot(
                        context,
                        label: '1st',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => _openAddOfficial(context, 'scorer'),
                      ),
                      _officialSlot(
                        context,
                        label: '2nd',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => _openAddOfficial(context, 'scorer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Select commentators'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _officialSlot(
                        context,
                        label: '1st',
                        icon: Icons.mic_none_rounded,
                        onTap: () => _openAddOfficial(context, 'commentator'),
                      ),
                      _officialSlot(
                        context,
                        label: '2nd',
                        icon: Icons.mic_none_rounded,
                        onTap: () => _openAddOfficial(context, 'commentator'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Others'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _officialSlot(
                        context,
                        label: 'Referee',
                        icon: Icons.badge_outlined,
                        onTap: () => _openAddOfficial(context, 'official'),
                      ),
                      _officialSlot(
                        context,
                        label: 'Streamer',
                        icon: Icons.videocam_outlined,
                        onTap: () => _openAddOfficial(context, 'streamer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  static Widget _officialSlot(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openAddOfficial(BuildContext context, String role) async {
    String title;
    String hint;
    TextInputType keyboardType = TextInputType.phone;

    if (role == 'umpire') {
      title = 'Add Officials';
      hint = 'Add via phone number';
    } else if (role == 'scorer') {
      title = 'Add Officials';
      hint = 'Add via phone number';
    } else if (role == 'commentator') {
      title = 'Add Officials';
      hint = 'Add via phone number';
    } else {
      title = 'Add live streamer';
      hint = 'Add via phone number or email';
      keyboardType = TextInputType.emailAddress;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOfficialByPhoneScreen(
          title: title,
          hintText: hint,
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}

class AddOfficialByPhoneScreen extends StatelessWidget {
  final String title;
  final String hintText;
  final TextInputType keyboardType;

  const AddOfficialByPhoneScreen({
    super.key,
    required this.title,
    required this.hintText,
    this.keyboardType = TextInputType.phone,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Find by ${keyboardType == TextInputType.emailAddress ? 'phone or email' : 'phone'} – coming soon'),
                    ),
                  );
                },
                child: const Text(
                  'Find',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

