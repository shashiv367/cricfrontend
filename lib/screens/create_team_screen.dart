import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _teamNameController = TextEditingController();
  final _cityController = TextEditingController(text: 'Hyderabad (Telangana)');
  final _captainNumberController = TextEditingController();
  final _captainNameController = TextEditingController();
  bool _addMyself = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 2;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teamNameController.dispose();
    _cityController.dispose();
    _captainNumberController.dispose();
    _captainNameController.dispose();
    super.dispose();
  }

  void _onAddTeam() {
    final name = _teamNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter team name'), backgroundColor: AppColors.accentSunset),
      );
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Create your team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.backgroundWhite,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryElectric,
              indicatorWeight: 3,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Your Teams'),
                Tab(text: 'Opponents'),
                Tab(text: 'Add'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryElectric.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_cricket_rounded, size: 40, color: AppColors.primaryElectric.withOpacity(0.7)),
                              const SizedBox(height: 4),
                              Text(
                                'Team logo',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: AppColors.textPrimary.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Team logo', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _teamNameController,
                    decoration: InputDecoration(
                      hintText: 'Team name *',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'City / town *',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _captainNumberController,
                    decoration: InputDecoration(
                      hintText: '+91 Team captain/coordinator number (optional)',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      suffixIcon: Icon(Icons.contact_phone_outlined, size: 22, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _captainNameController,
                    decoration: InputDecoration(
                      hintText: 'Team captain name (optional)',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _addMyself,
                          onChanged: (v) => setState(() => _addMyself = v ?? false),
                          activeColor: AppColors.primaryElectric,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Add myself in team', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Material(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _onAddTeam,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    child: const Text('Add team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
