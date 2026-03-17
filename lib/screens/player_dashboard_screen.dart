import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  Map<String, dynamic>? _stats;
  String? _playerName;
  String? _teamName;
  String? _profilePictureUrl;
  File? _selectedImage;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProfile(), _loadStats()]);
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) {
        setState(() => _loading = false);
        return;
      }

      final response = await ApiService.getProfile(token);
      final profile = response['profile'];
      setState(() {
        _playerName = profile['full_name'] ?? 'Player';
        _nameController.text = profile['full_name'] ?? '';
        _emailController.text = profile['username'] ?? user.email ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _teamName = profile['team_name'] ?? 'Not assigned';
        _teamNameController.text = profile['team_name'] ?? '';
        _profilePictureUrl = profile['profile_picture_url'];
      });
    } catch (_) {
      // ignore for now
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Don't upload yet - wait for user to click "Save Changes"
        // This ensures all fields (team name, profile picture) are updated together
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<String?> _uploadProfilePicture() async {
    if (_selectedImage == null) return null;

    setState(() => _uploadingImage = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage avatars bucket
      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            _selectedImage!,
          );

      // Get public URL
      final imageUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      setState(() {
        _profilePictureUrl = imageUrl;
        _selectedImage = null; // Clear selected image after upload
        _uploadingImage = false;
      });

      return imageUrl;
    } catch (e) {
      setState(() => _uploadingImage = false);
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getPlayerStats(token: token, playerId: user.id);
      setState(() {
        _stats = response;
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      // Upload image if selected
      String? profilePictureUrl = _profilePictureUrl;
      if (_selectedImage != null && !_uploadingImage) {
        profilePictureUrl = await _uploadProfilePicture();
      }

      // Now update profile with all fields including team name and profile picture
      await ApiService.updateProfile(
        token: token,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        teamName: _teamNameController.text.trim().isEmpty 
            ? null 
            : _teamNameController.text.trim(),
        profilePictureUrl: profilePictureUrl,
      );
      
      setState(() {
        _teamName = _teamNameController.text.trim().isEmpty 
            ? 'Not assigned' 
            : _teamNameController.text.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: AppColors.lavenderBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.accentPurple)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lavenderBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPurple))
          : Stack(
              children: [
                // Global Wave Background for Hero
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 350,
                  child: CustomPaint(
                    painter: _WavePatternPainter(),
                  ),
                ),
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 300,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.lavenderBg.withOpacity(0.8),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Profile Photo with Glowing Ring
                                  _buildGlowProfilePhoto(),
                                  const SizedBox(height: 16),
                                  // Player Name
                                  Text(
                                    _playerName ?? 'Player',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your cricket profile',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Team Badge
                                  _buildTeamBadge(),
                                  const SizedBox(height: 20),
                                  // 3 Pills Stat Row (Mockup Style)
                                  _buildHeroStatPills(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.logout_rounded),
                            color: AppColors.accentPurple,
                            onPressed: _handleLogout,
                          ),
                        ],
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController!,
                            labelColor: AppColors.accentPurple,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: AppColors.accentPurple,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'DASHBOARD'),
                              Tab(text: 'PROFILE'),
                            ],
                          ),
                          AppColors.lavenderBg,
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController!,
                    children: [
                      _buildDashboardTab(),
                      _buildProfileTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGlowProfilePhoto() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              gradient: LinearGradient(
                colors: [AppColors.accentPurple, AppColors.profileRing],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: _profilePictureUrl != null
                      ? Image.network(_profilePictureUrl!, fit: BoxFit.cover)
                      : _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : _buildAvatarFallback(),
                ),
              ),
            ),
          ),
          if (_uploadingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.profileRing.withOpacity(0.3)),
      ),
      child: Text(
        _teamName ?? 'No Team',
        style: TextStyle(
          color: AppColors.accentPurple,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHeroStatPills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMiniPill('45 M', Icons.event_note_rounded, AppColors.accentPurple.withOpacity(0.1)),
        const SizedBox(width: 8),
        _buildMiniPill('2.5K R', Icons.sports_cricket_rounded, const Color(0xFF6B9EDB).withOpacity(0.1)),
        const SizedBox(width: 8),
        _buildMiniPill('28 W', Icons.sports_baseball_rounded, const Color(0xFFDB6B7F).withOpacity(0.1)),
      ],
    );
  }

  Widget _buildMiniPill(String text, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.accentPurple),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.profileRing.withOpacity(0.3),
      ),
      child: Center(
        child: Text(
          _playerName?.isNotEmpty == true ? _playerName!.substring(0, 1).toUpperCase() : 'P',
          style: TextStyle(
            color: AppColors.accentPurple,
            fontSize: 28,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CricInsights-style: Performance / Insights block
          _buildInsightsBlock(),
          const SizedBox(height: 20),
          // 2. Badges & Awards (CricHeroes-style recognition)
          _buildBadgesSection(),
          const SizedBox(height: 20),
          // 3. Recent Form Section
          _buildRecentFormCard(),
          const SizedBox(height: 20),
          // 4. Detailed Statistics Card
          _buildDetailedStatsCard(),
          const SizedBox(height: 24),
          // 5. Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInsightsBlock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insights_rounded, color: AppColors.accentPurple, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'CricInsights',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Form, preferred positions & compare with others.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInsightChip('Form', 'Good'),
                  const SizedBox(width: 8),
                  _buildInsightChip('Bat Pos', 'Top order'),
                  const SizedBox(width: 8),
                  _buildInsightChip('Bowl', 'Middle'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Badges & Awards',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recognition for your achievements on the ground.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildBadgePlaceholder(Icons.emoji_events_rounded, 'Centurion'),
                  const SizedBox(width: 12),
                  _buildBadgePlaceholder(Icons.star_rounded, 'Player of Match'),
                  const SizedBox(width: 12),
                  _buildBadgePlaceholder(Icons.trending_up_rounded, 'Rising Star'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgePlaceholder(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.profileRing),
          ),
          child: Icon(icon, color: AppColors.accentPurple, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Form',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFormIndicator('Won', AppColors.softGreen, Icons.check),
                  _buildFormIndicator('Won', AppColors.softGreen, Icons.check),
                  _buildFormIndicator('Lost', const Color(0xFFF43F5E), Icons.close),
                  _buildFormIndicator('Lost', const Color(0xFFF43F5E), Icons.close),
                  _buildFormIndicator('No Result', const Color(0xFFFB923C), Icons.remove),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormIndicator(String label, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStatsCard() {
    return Container(
      decoration: _glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatItem('Runs', _stats?['batting']?['totalRuns']?.toString() ?? '2,540', Icons.sports_cricket_rounded, AppColors.accentPurple),
                    _buildVerticalDivider(),
                    _buildStatItem('Balls', '1,745', Icons.sports_baseball_rounded, const Color(0xFF6B9EDB)),
                  ],
                ),
                _buildHorizontalDivider(),
                Row(
                  children: [
                    _buildStatItem('Fours', _stats?['batting']?['totalFours']?.toString() ?? '260', Icons.architecture_rounded, const Color(0xFFB8A9E8)),
                    _buildVerticalDivider(),
                    _buildStatItem('SR', _stats?['batting']?['strikeRate']?.toString() ?? '145.78', Icons.speed_rounded, const Color(0xFF7E6FCC)),
                  ],
                ),
                _buildHorizontalDivider(),
                Row(
                  children: [
                    _buildStatItem('Sixes', _stats?['batting']?['totalSixes']?.toString() ?? '60', Icons.sports_cricket_rounded, const Color(0xFFDB6B7F)),
                    _buildVerticalDivider(),
                    _buildStatItem('HS', '104*', Icons.emoji_events_rounded, const Color(0xFFF09B7A)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildHorizontalDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 20),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9E92FF), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
              child: const Text(
                'View Full Stats',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: AppColors.profileRing.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Share Profile',
                style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentPurple.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }



  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              color: AppColors.accentPurple,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 24),
          _inputField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          _inputField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _inputField(
            controller: _phoneController,
            label: 'Mobile Number',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
          ),
          _inputField(
            controller: _teamNameController,
            label: 'Team Name',
            icon: Icons.group_rounded,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
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



  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.profileRing.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.profileRing.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accentPurple, size: 20),
            ),
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.profileRing.withOpacity(0.3), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _color;

  _SliverAppBarDelegate(this._tabBar, this._color);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPurple.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      double yOffset = i * 45.0;
      path.moveTo(0, 80 + yOffset);
      
      for (double x = 0; x <= size.width; x += 15) {
        double y = 80 + yOffset + 
                   (15 * (i + 1) * 0.4) * 
                   math.sin((x / size.width * 2.5 * math.pi) + (i * 1.2));
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
