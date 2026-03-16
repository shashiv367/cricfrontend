import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Contact cricheroes'),
        backgroundColor: AppColors.primaryElectric,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accentTeal,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Write'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWriteTab(context),
          _buildChatTab(context),
        ],
      ),
    );
  }

  Widget _buildWriteTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thank you for writing to us. We will get back as soon as possible.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'Name*',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: 'Mobile number*',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _commentController,
            label: 'Comment*',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                children: [
                  const TextSpan(
                    text: 'If you are planning to organise a tournament\n',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/add-tournament');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Click here',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: () {
                // Placeholder action for now
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent (demo only).'),
                  ),
                );
              },
              child: const Text(
                'Send',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Hey there, stuck somewhere? We\'re here to help!\n'
            'Send us a WhatsApp message and we\'ll try to assist you\n'
            'faster than Bumrah\'s yorker!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '+91 8141665555',
            style: TextStyle(
              color: AppColors.accentRed,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Click on the icon to call',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                children: [
                  const TextSpan(
                    text: 'If you are planning to organise a tournament\n',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/add-tournament');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Click here',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppColors.primaryElectric,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

