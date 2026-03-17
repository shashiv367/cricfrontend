import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class SelectUmpireScreen extends StatefulWidget {
  const SelectUmpireScreen({super.key});

  @override
  State<SelectUmpireScreen> createState() => _SelectUmpireScreenState();
}

class _SelectUmpireScreenState extends State<SelectUmpireScreen> {
  List<Map<String, dynamic>> _umpires = [];
  bool _loading = true;
  String? _error;

  static const List<Map<String, dynamic>> _fallbackUmpires = [
    {'name': 'Ramesh Kumar', 'city': 'Hyderabad (Telangana)', 'matches': 48},
    {'name': 'Sneha Verma', 'city': 'Hyderabad (Telangana)', 'matches': 35},
    {'name': 'Irfan Ahmed', 'city': 'Secunderabad', 'matches': 60},
  ];

  @override
  void initState() {
    super.initState();
    _loadUmpires();
  }

  Future<void> _loadUmpires() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = supabase.auth.currentSession?.accessToken;
      if (token == null) {
        setState(() {
          _umpires = List.from(_fallbackUmpires);
          _loading = false;
        });
        return;
      }
      final res = await ApiService.listUmpires(token);
      final list = res['umpires'] as List<dynamic>?;
      final items = list != null
          ? list.map((e) => _normalizeUmpire(e as Map<String, dynamic>)).toList()
          : <Map<String, dynamic>>[];
      if (mounted) {
        setState(() {
          _umpires = items.isNotEmpty ? items : List.from(_fallbackUmpires);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _umpires = List.from(_fallbackUmpires);
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Map<String, dynamic> _normalizeUmpire(Map<String, dynamic> u) {
    return {
      'id': u['id'],
      'name': u['name']?.toString() ?? 'Umpire',
      'city': u['city']?.toString() ?? '—',
      'matches': (u['matches'] is int) ? u['matches'] as int : 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: const Text('Select umpire'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryElectric))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: _umpires.length,
                    itemBuilder: (context, index) {
                      return _buildUmpireCard(context, _umpires[index]);
                    },
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Using cached list.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.divider),
                      ),
                      child: const Text('Skip for now'),
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

  Widget _buildUmpireCard(BuildContext context, Map<String, dynamic> umpire) {
    final name = umpire['name'] as String;
    final city = umpire['city'] as String? ?? '—';
    final matches = (umpire['matches'] is int) ? umpire['matches'] as int : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryElectric.withOpacity(0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryElectric,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        city,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$matches matches',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Switch(
                value: false,
                activeColor: AppColors.primaryTeal,
                onChanged: (value) {},
              ),
              const SizedBox(height: 4),
              const Text(
                'Assign',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
