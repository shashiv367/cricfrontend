import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'add_team_players_screen.dart';

class UmpireMatchManagementScreen extends StatefulWidget {
  const UmpireMatchManagementScreen({super.key});

  @override
  State<UmpireMatchManagementScreen> createState() => _UmpireMatchManagementScreenState();
}

class _UmpireMatchManagementScreenState extends State<UmpireMatchManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _locationController = TextEditingController();
  final _oversController = TextEditingController(text: '20');

  List<Map<String, dynamic>> _locations = [];
  String? _selectedLocationId;
  bool _useNewLocation = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listLocations(token);
      setState(() {
        _locations = List<Map<String, dynamic>>.from(response['locations'] ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load locations: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _locationController.dispose();
    _oversController.dispose();
    super.dispose();
  }

  Future<void> _createMatch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_useNewLocation && _selectedLocationId == null && _locations.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a location or create a new one'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) {
        throw Exception('No session token');
      }

      final overs = int.tryParse(_oversController.text) ?? 20;

      final response = await ApiService.createMatch(
        token: token,
        teamAName: _teamAController.text.trim(),
        teamBName: _teamBController.text.trim(),
        locationId: _useNewLocation ? null : _selectedLocationId,
        locationName: _useNewLocation ? _locationController.text.trim() : null,
        overs: overs,
      );

      if (mounted) {
        // Navigate to add Team A players
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AddTeamPlayersScreen(
              matchId: response['matchId'],
              teamName: _teamAController.text.trim(),
              teamId: null, // Will be fetched from match details
              isTeamA: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create match: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text(
          'Create Match',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.2),
                    AppColors.backgroundWhite,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_cricket_rounded,
                      size: 48,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Set Up Your Match',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure teams, location, and match settings',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team A Card
                    _teamCard(
                      controller: _teamAController,
                      label: 'Team A',
                      icon: Icons.flag_rounded,
                      color: AppColors.primaryPurple,
                      hint: 'Enter Team A name',
                    ),
                    const SizedBox(height: 20),

                    // VS Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.textMuted.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhiteAlt,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.textMuted.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.textMuted.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Team B Card
                    _teamCard(
                      controller: _teamBController,
                      label: 'Team B',
                      icon: Icons.flag_outlined,
                      color: AppColors.accentRed,
                      hint: 'Enter Team B name',
                    ),
                    const SizedBox(height: 24),

                    // Overs Card
                    _settingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                color: AppColors.primaryPurple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Overs',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _oversController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textPrimary),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final val = int.tryParse(v);
                              if (val == null || val < 1) return 'Enter valid number';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '20',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.backgroundWhiteAlt,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.backgroundWhiteAlt,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryPurple,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.accentRed,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.accentRed,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location Section
                    _settingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primaryPurple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Location',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!_useNewLocation && _locations.isNotEmpty) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhiteAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.backgroundWhiteAlt,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedLocationId,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.location_city_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  hintText: 'Select location',
                                  hintStyle: TextStyle(color: AppColors.textMuted),
                                  filled: true,
                                  fillColor: AppColors.backgroundWhiteAlt,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryPurple,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                dropdownColor: AppColors.backgroundWhite,
                                style: const TextStyle(color: AppColors.textPrimary),
                                items: _locations.map((loc) {
                                  return DropdownMenuItem(
                                    value: loc['id'].toString(),
                                    child: Text(loc['name'] ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedLocationId = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _useNewLocation = true;
                                  _selectedLocationId = null;
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              label: const Text('Add New Location'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryPurple,
                              ),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _locationController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.location_city_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                hintText: 'Enter location name',
                                hintStyle: TextStyle(color: AppColors.textMuted),
                                filled: true,
                                fillColor: AppColors.backgroundWhiteAlt,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.backgroundWhiteAlt,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryPurple,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentRed,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentRed,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (_locations.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _useNewLocation = false;
                                    _locationController.clear();
                                  });
                                },
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Select Existing Location'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create Match Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _createMatch,
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_circle_outline_rounded, size: 24),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Create Match',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return Container(
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
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.backgroundWhiteAlt,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.backgroundWhiteAlt,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accentRed,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accentRed,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.backgroundWhiteAlt,
        ),
      ),
      child: child,
    );
  }
}
