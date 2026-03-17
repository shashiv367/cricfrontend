import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';
import '../services/match_service.dart';

class MatchOfficialsScreen extends StatelessWidget {
  final String? matchId;
  final String? inviteCode;

  const MatchOfficialsScreen({
    super.key,
    this.matchId,
    this.inviteCode,
  });

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
                        onTap: () => _openAddOfficial(context, 'umpire', matchId, inviteCode),
                      ),
                      _officialSlot(
                        context,
                        label: '2nd',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire', matchId, inviteCode),
                      ),
                      _officialSlot(
                        context,
                        label: '3rd',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire', matchId, inviteCode),
                      ),
                      _officialSlot(
                        context,
                        label: '4th',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _openAddOfficial(context, 'umpire', matchId, inviteCode),
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
                        onTap: () => _openAddOfficial(context, 'scorer', matchId, inviteCode),
                      ),
                      _officialSlot(
                        context,
                        label: '2nd',
                        icon: Icons.receipt_long_outlined,
                        onTap: () => _openAddOfficial(context, 'scorer', matchId, inviteCode),
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
                        onTap: () => _openAddOfficial(context, 'commentator', matchId, inviteCode),
                      ),
                      _officialSlot(
                        context,
                        label: '2nd',
                        icon: Icons.mic_none_rounded,
                        onTap: () => _openAddOfficial(context, 'commentator', matchId, inviteCode),
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
                        onTap: () => _openAddOfficial(context, 'official', matchId, inviteCode),
                      ),
                      _officialSlot(
                        context,
                        label: 'Streamer',
                        icon: Icons.videocam_outlined,
                        onTap: () => _openAddOfficial(context, 'streamer', matchId, inviteCode),
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
                    style: TextStyle(fontWeight: FontWeight.normal),
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
        fontWeight: FontWeight.normal,
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

  static Future<void> _openAddOfficial(
    BuildContext context,
    String role,
    String? matchId,
    String? inviteCode,
  ) async {
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
          matchId: matchId,
          inviteCode: inviteCode,
        ),
      ),
    );
  }
}

class AddOfficialByPhoneScreen extends StatefulWidget {
  final String title;
  final String hintText;
  final TextInputType keyboardType;
  final String? matchId;
  final String? inviteCode;

  const AddOfficialByPhoneScreen({
    super.key,
    required this.title,
    required this.hintText,
    this.keyboardType = TextInputType.phone,
    this.matchId,
    this.inviteCode,
  });

  @override
  State<AddOfficialByPhoneScreen> createState() => _AddOfficialByPhoneScreenState();
}

class _AddOfficialByPhoneScreenState extends State<AddOfficialByPhoneScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  final _matchService = MatchService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isValidPhoneDigits(String digits) {
    // Simple pragmatic validation for QA: 10-15 digits after cleaning.
    return digits.length >= 10 && digits.length <= 15;
  }

  bool _isValidEmail(String email) {
    final v = email.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  }

  String _normalizePhoneForWhatsApp(String digits) {
    // WhatsApp requires country code. If user enters 10 digits, assume India (+91).
    if (digits.length == 10) return '91$digits';
    return digits;
  }

  String _buildInviteMessage(String code) {
    final joinDeepLink = 'innings://join-match?code=$code';
    return 'Join my match on Innings.\n\nInvite code: $code\nJoin link: $joinDeepLink';
  }

  Future<void> _sendInvite() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      _showError('Empty field');
      return;
    }

    final isEmailMode = widget.keyboardType == TextInputType.emailAddress;
    if (isEmailMode) {
      if (!_isValidEmail(raw)) {
        _showError('Invalid email');
        return;
      }
      _showError('Email invite is coming soon');
      return;
    }

    final digits = _digitsOnly(raw);
    if (!_isValidPhoneDigits(digits)) {
      _showError('Invalid number');
      return;
    }

    setState(() => _sending = true);
    try {
      String? code = widget.inviteCode;
      if ((code == null || code.trim().isEmpty) && widget.matchId != null) {
        code = await _matchService.getInviteCode(widget.matchId!);
      }
      if (code == null || code.trim().isEmpty) {
        _showError('Please save the match first.');
        return;
      }

      final message = _buildInviteMessage(code.trim());
      final waPhone = _normalizePhoneForWhatsApp(digits);
      final waUri = Uri.parse('https://wa.me/$waPhone?text=${Uri.encodeComponent(message)}');
      final smsUri = Uri.parse('sms:$digits?body=${Uri.encodeComponent(message)}');

      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send invite link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+$waPhone',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryElectric),
                    title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.normal)),
                    onTap: () async {
                      Navigator.pop(context);
                      if (await canLaunchUrl(waUri)) {
                        await launchUrl(waUri, mode: LaunchMode.externalApplication);
                      } else {
                        _showError('WhatsApp not available');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sms_outlined, color: AppColors.primaryElectric),
                    title: const Text('SMS', style: TextStyle(fontWeight: FontWeight.normal)),
                    onTap: () async {
                      Navigator.pop(context);
                      if (await canLaunchUrl(smsUri)) {
                        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
                      } else {
                        _showError('SMS not available');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  hintText: widget.hintText,
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
                onPressed: _sending ? null : _sendInvite,
                child: const Text(
                  'Find',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

