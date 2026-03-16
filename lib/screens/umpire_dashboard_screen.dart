import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import '../services/auth_service.dart';
import 'umpire_match_management_screen.dart';
import 'umpire_live_matches_screen.dart';
import 'auth_screen.dart';

class UmpireDashboardScreen extends StatefulWidget {
  const UmpireDashboardScreen({super.key});

  @override
  State<UmpireDashboardScreen> createState() => _UmpireDashboardScreenState();
}

class _UmpireDashboardScreenState extends State<UmpireDashboardScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _umpireName;
  String? _profilePictureUrl;
  File? _selectedImage;
  TabController? _tabController;
  List<Map<String, dynamic>> _previousMatches = [];
  bool _loadingMatches = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProfile(), _loadPreviousMatches()]);
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
        _umpireName = profile['full_name'] ?? 'Umpire';
        _nameController.text = profile['full_name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _profilePictureUrl = profile['profile_picture_url'];
      });
    } catch (_) {
      // ignore for now
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPreviousMatches() async {
    setState(() => _loadingMatches = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listUmpireMatches(token);
      final matches = response['matches'] as List<dynamic>? ?? [];
      
      // Filter only completed matches
      final completedMatches = matches.where((match) => match['status'] == 'completed').toList();
      
      // Get score details for each match in parallel
      final matchDetailFutures = completedMatches.map((match) async {
        try {
          final matchDetails = await ApiService.getMatchDetails(token: token, matchId: match['id']);
          if (matchDetails['match'] != null && matchDetails['match']['score'] != null) {
            return {
              ...match,
              'score': matchDetails['match']['score'],
            } as Map<String, dynamic>;
          } else {
            return match as Map<String, dynamic>;
          }
        } catch (_) {
          return match as Map<String, dynamic>;
        }
      }).toList();
      
      final matchesWithScores = await Future.wait(matchDetailFutures);
      
      setState(() {
        _previousMatches = matchesWithScores;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingMatches = false);
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
        _selectedImage = null;
        _uploadingImage = false;
      });

      return imageUrl;
    } catch (e) {
      setState(() => _uploadingImage = false);
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      // Upload image if selected, otherwise use existing URL
      String? profilePictureUrl = _profilePictureUrl;
      if (_selectedImage != null && !_uploadingImage) {
        try {
          profilePictureUrl = await _uploadProfilePicture();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: AppColors.accentRed,
              ),
            );
          }
          setState(() => _saving = false);
          return;
        }
      }

      // Prepare all fields - send empty strings as empty strings to clear fields if needed
      final fullName = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      // Update profile with all fields - backend will handle empty strings appropriately
      await ApiService.updateProfile(
        token: token,
        fullName: fullName,
        phone: phone,
        profilePictureUrl: profilePictureUrl, // Send existing URL or newly uploaded URL
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
        // Reload profile to get updated data
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 3),
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
  void dispose() {
    _tabController?.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : NestedScrollView(
              key: const PageStorageKey('umpire_dashboard'),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 240,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.backgroundWhite,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryPurple.withOpacity(0.3),
                              AppColors.backgroundWhite,
                              AppColors.backgroundLight,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Profile Picture
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryPurple,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryPurple.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _profilePictureUrl != null
                                              ? Image.network(
                                                  _profilePictureUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors.backgroundWhiteAlt,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _umpireName?.isNotEmpty == true
                                                              ? _umpireName!.substring(0, 1).toUpperCase()
                                                              : 'U',
                                                          style: const TextStyle(
                                                            color: AppColors.primaryPurple,
                                                            fontSize: 36,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : _selectedImage != null
                                                  ? Image.file(
                                                      _selectedImage!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors.backgroundWhiteAlt,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _umpireName?.isNotEmpty == true
                                                              ? _umpireName!.substring(0, 1).toUpperCase()
                                                              : 'U',
                                                          style: const TextStyle(
                                                            color: AppColors.primaryPurple,
                                                            fontSize: 36,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                        ),
                                      ),
                                      if (_uploadingImage)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(0.5),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primaryPurple,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primaryPurple,
                                            border: Border.all(
                                              color: AppColors.backgroundWhite,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _umpireName ?? 'Umpire',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports_handball_rounded,
                                      color: AppColors.primaryPurple,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Match Official',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        color: AppColors.textSecondary,
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController!,
                        labelColor: AppColors.primaryPurple,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primaryPurple,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.dashboard_rounded),
                            text: 'Dashboard',
                          ),
                          Tab(
                            icon: Icon(Icons.person_rounded),
                            text: 'Profile',
                          ),
                        ],
                      ),
                      AppColors.backgroundWhite,
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
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadPreviousMatches,
      color: AppColors.primaryPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Cards
            _actionCard(
              title: 'Create Match',
              subtitle: 'Set up teams, select or add location, configure overs',
              icon: Icons.add_circle_outline_rounded,
              color: AppColors.primaryPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UmpireMatchManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _actionCard(
              title: 'My Matches',
              subtitle: 'View and manage your created matches, update scores and player stats',
              icon: Icons.live_tv_rounded,
              color: AppColors.accentRed,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UmpireLiveMatchesScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Previous Matches Section
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Previous Matches',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_loadingMatches)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primaryPurple),
                ),
              )
            else if (_previousMatches.isEmpty)
              _noMatchesCard()
            else
              ..._previousMatches.map((match) => _previousMatchCard(match)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _noMatchesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundWhiteAlt),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: AppColors.textMuted,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No Previous Matches',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed matches will appear here',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _previousMatchCard(Map<String, dynamic> match) {
    final teamA = match['team_a'] as Map<String, dynamic>?;
    final teamB = match['team_b'] as Map<String, dynamic>?;
    final score = match['score'] as Map<String, dynamic>?;
    final location = match['location'] as Map<String, dynamic>?;
    
    final teamAName = teamA?['name'] ?? 'Team A';
    final teamBName = teamB?['name'] ?? 'Team B';
    final locationName = location?['name'] ?? 'Unknown Location';
    
    final teamAScore = score?['team_a_score'] ?? 0;
    final teamAWkts = score?['team_a_wkts'] ?? 0;
    final teamAOvers = score?['team_a_overs'] ?? 0.0;
    final teamBScore = score?['team_b_score'] ?? 0;
    final teamBWkts = score?['team_b_wkts'] ?? 0;
    final teamBOvers = score?['team_b_overs'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundWhiteAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                ),
                child: Text(
                  'Completed',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.location_on_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                locationName,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamAName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$teamAScore/$teamAWkts (${teamAOvers.toStringAsFixed(1)} ov)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'VS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      teamBName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$teamBScore/$teamBWkts (${teamBOvers.toStringAsFixed(1)} ov)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _inputField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          _inputField(
            controller: _phoneController,
            label: 'Mobile Number',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundWhiteAlt),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primaryPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
