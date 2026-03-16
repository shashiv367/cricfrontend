import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'select_ground_screen.dart';

class AddTournamentScreen extends StatefulWidget {
  const AddTournamentScreen({super.key});

  @override
  State<AddTournamentScreen> createState() => _AddTournamentScreenState();
}

class _AddTournamentScreenState extends State<AddTournamentScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController(text: 'Hyderabad (Telangana)');
  final _groundController = TextEditingController();
  final _organiserNameController = TextEditingController(text: 'Shashi Vardhan');
  final _organiserNumberController = TextEditingController(text: '9063531983');
  final _organiserEmailController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _ballType;
  final List<String> _categoryOptions = ['OPEN', 'CORPORATE', 'COMMUNITY', 'SCHOOL', 'UNIVERSITY', 'OTHER', 'SERIES', 'COLLEGE'];
  final List<String> _pitchOptions = ['ROUGH', 'CEMENT', 'TURF', 'ASTROTURF', 'MATTING'];
  final List<String> _matchTypeOptions = ['Limited Overs', 'Box/Turf Cricket', 'Pair Cricket', 'Test Match', 'The Hundred'];
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedPitch = {};
  final Set<String> _selectedMatchType = {};
  bool _needMoreTeams = false;
  bool _needOfficials = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _groundController.dispose();
    _organiserNameController.dispose();
    _organiserNumberController.dispose();
    _organiserEmailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
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
        title: const Text('Add a tournament / series', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.play_arrow, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddBanner(),
            const SizedBox(height: 20),
            _buildAddLogo(),
            const SizedBox(height: 24),
            _buildLabel('Tournament / series name *'),
            _buildUnderlineField(_nameController, 'Tournament / series name'),
            _buildLabel('City *'),
            _buildUnderlineField(_cityController, 'City'),
            _buildLabel('Ground *'),
            _buildGroundField(),
            _buildLabel('Organiser name *'),
            _buildUnderlineField(_organiserNameController, 'Organiser name'),
            _buildLabel('Organiser number *'),
            _buildUnderlineField(_organiserNumberController, 'Organiser number'),
            _buildLabel('Organiser email'),
            _buildUnderlineField(_organiserEmailController, 'Organiser email'),
            const SizedBox(height: 4),
            Text('*get updated with CricHeroes offers and help videos on mail.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Text('Tournament dates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildUnderlineField(_startDateController, 'Start date *')),
                const SizedBox(width: 16),
                Expanded(child: _buildUnderlineField(_endDateController, 'End date *')),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Tournament category*'),
            const SizedBox(height: 8),
            _buildChips(_categoryOptions, _selectedCategories, single: false),
            const SizedBox(height: 24),
            _buildLabel('Select ball type*'),
            const SizedBox(height: 12),
            _buildBallTypeRow(),
            const SizedBox(height: 24),
            _buildLabel('Pitch type'),
            const SizedBox(height: 8),
            _buildChips(_pitchOptions, _selectedPitch, single: false),
            const SizedBox(height: 24),
            _buildLabel('Match type*'),
            const SizedBox(height: 8),
            _buildChips(_matchTypeOptions, _selectedMatchType, single: false),
            const SizedBox(height: 20),
            _buildCheckbox('Do you need more teams for your tournament?', _needMoreTeams, (v) => setState(() => _needMoreTeams = v ?? false)),
            _buildCheckbox('Do you need officials? (e.g. Umpire, Scorer)', _needOfficials, (v) => setState(() => _needOfficials = v ?? false)),
            const SizedBox(height: 32),
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
                  child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBanner() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundCardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary)),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.primaryElectric, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Add banner', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildAddLogo() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.backgroundCardAlt,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: Icon(Icons.image_outlined, size: 32, color: AppColors.textSecondary),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primaryElectric, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Text('Add logo', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
    );
  }

  Widget _buildUnderlineField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  Widget _buildGroundField() {
    final value = _groundController.text;
    return InkWell(
      onTap: () async {
        final selected = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const SelectGroundScreen()),
        );
        if (selected != null && mounted) {
          setState(() => _groundController.text = selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'Select ground *' : value,
                style: TextStyle(
                  fontSize: 16,
                  color: value.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(List<String> options, Set<String> selected, {bool single = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((label) {
        final isSelected = selected.contains(label);
        return FilterChip(
          label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
          selected: isSelected,
          onSelected: (v) {
            setState(() {
              if (single) {
                selected.clear();
                if (v) selected.add(label);
              } else {
                if (v) selected.add(label); else selected.remove(label);
              }
            });
          },
          backgroundColor: AppColors.backgroundCardAlt,
          selectedColor: AppColors.primaryTeal,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildBallTypeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBallOption('Tennis', Icons.sports_baseball_rounded, AppColors.primaryTeal, 'tennis'),
        _buildBallOption('Leather', Icons.sports_cricket_rounded, AppColors.accentSunset, 'leather'),
        _buildBallOption('Other', Icons.more_horiz_rounded, AppColors.accentGlow, 'other'),
      ],
    );
  }

  Widget _buildBallOption(String label, IconData icon, Color color, String value) {
    final selected = _ballType == value;
    return GestureDetector(
      onTap: () => setState(() => _ballType = value),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryTeal : color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: selected ? AppColors.primaryTeal : color, width: 2),
            ),
            child: Icon(selected ? Icons.check : icon, color: selected ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryElectric,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
