import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'dart:developer' as developer;

class SelectSquadScreen extends StatefulWidget {
  final String teamName;
  final String? teamId;
  final bool addMyself;
  final Set<String> blockedPlayers;

  const SelectSquadScreen({
    super.key,
    required this.teamName,
    this.teamId,
    this.addMyself = false,
    this.blockedPlayers = const {},
  });

  @override
  State<SelectSquadScreen> createState() => _SelectSquadScreenState();
}

class _SelectSquadScreenState extends State<SelectSquadScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _registeredPlayers = [];
  final List<String> _allPlayers = [];
  final Set<String> _selected = {};
  bool _loadingPlayers = true;

  void _showBlockedMessage(String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name is already selected in the opposite team'),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isBlocked(String name) {
    // Compare case-insensitively to avoid duplicates like "Rohit" vs "rohit".
    final n = name.trim().toLowerCase();
    return widget.blockedPlayers.any((b) => b.trim().toLowerCase() == n);
  }

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _loadingPlayers = true);
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) {
        if (mounted) {
          setState(() {
            _registeredPlayers.clear();
            _allPlayers
              ..clear();
            _loadingPlayers = false;
          });
        }
        return;
      }

      // If teamId is provided, load only the players already stored for this team
      // (via match_player_stats) so "teams" behave per-user and don't show everyone.
      if (widget.teamId != null && widget.teamId!.trim().isNotEmpty) {
        final teamId = widget.teamId!;
        final stats = await supabase
            .from('match_player_stats')
            .select('player_name')
            .eq('team_id', teamId)
            .order('created_at', ascending: false)
            .limit(200);

        final names = <String>[];
        for (final s in (stats as List<dynamic>? ?? [])) {
          final name = (s as Map<dynamic, dynamic>)['player_name']?.toString().trim() ?? '';
          if (name.isNotEmpty) names.add(name);
        }

        if (!mounted) return;
        setState(() {
          _registeredPlayers.clear();
          _allPlayers
            ..clear()
            ..addAll(names.toSet().toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));
        });
      } else {
        final resp = await ApiService.listPlayers(token);
        final players = List<Map<String, dynamic>>.from(resp['players'] ?? []);

        // Convert to display names (prefer full_name, else username/email prefix, else phone)
        final names = <String>[];
        for (final p in players) {
          final full = (p['full_name'] ?? '').toString().trim();
          final username = (p['username'] ?? '').toString().trim();
          final phone = (p['phone'] ?? '').toString().trim();
          String display = full.isNotEmpty ? full : username;
          if (display.isEmpty && phone.isNotEmpty) display = phone;
          if (display.isNotEmpty) names.add(display);
        }

        if (!mounted) return;
        setState(() {
          _registeredPlayers
            ..clear()
            ..addAll(players);
          _allPlayers
            ..clear()
            ..addAll(names.toSet().toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));
        });
      }

      if (widget.addMyself) {
        final user = supabase.auth.currentUser;
        String me = (user?.userMetadata?['full_name'] ?? '').toString().trim();
        if (me.isEmpty) {
          final email = (user?.email ?? '').trim();
          if (email.isNotEmpty) me = email.split('@').first;
        }
        if (me.isNotEmpty) {
          if (_isBlocked(me)) {
            // If "me" is already used by opposite team, don't auto-select.
            return;
          }
          setState(() {
            if (!_allPlayers.contains(me)) _allPlayers.insert(0, me);
            _selected.add(me);
          });
        }
      }
    } catch (e) {
      developer.log('Failed to load registered players: $e');
      if (mounted) {
        setState(() => _loadingPlayers = false);
      }
      return;
    } finally {
      if (mounted) setState(() => _loadingPlayers = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredPlayers {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _allPlayers;
    return _allPlayers.where((p) => p.toLowerCase().contains(q)).toList();
  }

  void _goToAssignRoles() {
    // Final safety: remove any blocked players that slipped in.
    _selected.removeWhere(_isBlocked);
    Navigator.push<SquadSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => AssignRolesScreen(
          teamName: widget.teamName,
          players: _selected.toList(),
        ),
      ),
    ).then((result) {
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text(widget.teamName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Select squad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selected
                        ..clear()
                        ..addAll(_allPlayers.where((p) => !_isBlocked(p)));
                    });
                  },
                  child: const Text(
                    'Select all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Quick search',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPlayersScreen(teamName: widget.teamName),
                        ),
                      );
                      if (!mounted || result == null) return;

                      // result can be {name, phone} from Add via phone/contacts
                      if (result is Map) {
                        final name = (result['name'] ?? '').toString().trim();
                        final phone = (result['phone'] ?? '').toString().trim();

                        // Try to match an existing registered user by phone (digits only)
                        final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
                        Map<String, dynamic>? matched;
                        if (digits.isNotEmpty) {
                          for (final p in _registeredPlayers) {
                            final pd = (p['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
                            if (pd.isNotEmpty && pd == digits) {
                              matched = p;
                              break;
                            }
                          }
                        }

                        String displayName = name;
                        if (matched != null) {
                          final full = (matched['full_name'] ?? '').toString().trim();
                          final username = (matched['username'] ?? '').toString().trim();
                          displayName = full.isNotEmpty ? full : username;
                        }

                        if (displayName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid player'), backgroundColor: AppColors.accentRed),
                          );
                          return;
                        }

                        if (_isBlocked(displayName)) {
                          _showBlockedMessage(displayName);
                          return;
                        }

                        setState(() {
                          if (!_allPlayers.contains(displayName)) _allPlayers.insert(0, displayName);
                          _selected.add(displayName);
                        });

                        // Notification: we cannot silently send messages; offer WhatsApp/SMS.
                        final notifyText = Uri.encodeComponent('You have been added to team "${widget.teamName}".');
                        final wa = digits.isNotEmpty ? Uri.parse('https://wa.me/$digits?text=$notifyText') : null;
                        if (wa != null) {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Notify player'),
                              content: Text('Send a message to $displayName that they were added to "${widget.teamName}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send WhatsApp')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await launchUrl(wa, mode: LaunchMode.externalApplication);
                          }
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Add player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingPlayers
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryElectric))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredPlayers.length,
                    itemBuilder: (context, index) {
                      final name = _filteredPlayers[index];
                      final selected = _selected.contains(name);
                      final blocked = _isBlocked(name);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.white,
                          leading: const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.backgroundCardAlt,
                            child: Icon(Icons.person, color: AppColors.textSecondary),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: blocked ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: const Text(
                            'Tap to select or deselect',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: Checkbox(
                            value: selected,
                            activeColor: AppColors.primaryTeal,
                            onChanged: blocked
                                ? null
                                : (v) {
                              setState(() {
                                if (v ?? false) {
                                  _selected.add(name);
                                } else {
                                  _selected.remove(name);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            if (blocked) {
                              _showBlockedMessage(name);
                              return;
                            }
                            setState(() {
                              if (selected) {
                                _selected.remove(name);
                              } else {
                                _selected.add(name);
                              }
                            });
                          },
                        ),
                      );
                    },
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _selected.isEmpty ? null : _goToAssignRoles,
                  child: const Text(
                    'Next',
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
}

class AddPlayersScreen extends StatefulWidget {
  final String teamName;

  const AddPlayersScreen({super.key, required this.teamName});

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  late final String _teamJoinCode;

  @override
  void initState() {
    super.initState();
    _teamJoinCode = _generateJoinCode();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(10, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  String get _teamJoinLink {
    // For now this is a shareable token for QA; you can later map it to a backend/deeplink route.
    final safeTeam = Uri.encodeComponent(widget.teamName);
    return 'innings://join-team?team=$safeTeam&code=$_teamJoinCode';
  }

  Future<void> _shareLink() async {
    await Share.share(_teamJoinLink, subject: 'Join ${widget.teamName}');
  }

  Future<void> _shareOnWhatsApp() async {
    final text = Uri.encodeComponent('Join my team "${widget.teamName}": $_teamJoinLink');
    final uri = Uri.parse('https://wa.me/?text=$text');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp not available'), backgroundColor: AppColors.accentRed),
      );
    }
  }

  Future<void> _addViaPhone() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add player via phone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Player name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );

    if (ok != true) return;
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter name and phone'), backgroundColor: AppColors.accentRed),
        );
      }
      return;
    }

    Navigator.pop(context, {'name': name, 'phone': phone});
  }

  Future<void> _addFromContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Contacts permission denied'),
            backgroundColor: AppColors.accentRed,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
      return;
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final c = contacts[i];
                final phone = c.phones.isNotEmpty ? c.phones.first.number : null;
                return ListTile(
                  title: Text(c.displayName),
                  subtitle: Text(phone ?? 'No phone number'),
                  enabled: phone != null && phone.trim().isNotEmpty,
                  onTap: (phone != null && phone.trim().isNotEmpty)
                      ? () {
                          Navigator.pop(ctx);
                          Navigator.pop(context, {'name': c.displayName, 'phone': phone});
                        }
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showQrCode() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Team QR code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: QrImageView(
                  data: _teamJoinLink,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                _teamJoinLink,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(onPressed: _shareLink, child: const Text('Share link')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text('Add players to ${widget.teamName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _methodCard(
            title: 'Team link',
            subtitle: 'Easiest way to add players.\nShare this link with captain and let them add their players.',
            leadingIcon: Icons.link,
            primaryAction: 'Share',
            secondaryAction: 'WhatsApp',
            onPrimary: _shareLink,
            onSecondary: _shareOnWhatsApp,
          ),
          _methodCard(
            title: 'Add via phone number',
            subtitle: 'Best for adding 1 or 2 players quickly.',
            leadingIcon: Icons.phone_android,
            primaryAction: 'Add',
            onPrimary: _addViaPhone,
          ),
          _methodCard(
            title: 'Add from contacts',
            subtitle: 'Best if players are already in your contacts.',
            leadingIcon: Icons.contacts_outlined,
            primaryAction: 'Pick',
            onPrimary: _addFromContacts,
          ),
          _methodCard(
            title: 'Team QR code',
            subtitle: 'Scan and add players directly via QR code.',
            leadingIcon: Icons.qr_code_2_outlined,
            primaryAction: 'Show',
            onPrimary: () async {
              _showQrCode();
            },
          ),
        ],
      ),
    );
  }

  Widget _methodCard({
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    String? primaryAction,
    String? secondaryAction,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.backgroundCardAlt,
                child: Icon(leadingIcon, color: AppColors.primaryElectric),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryElectric,
                    side: BorderSide(color: AppColors.primaryElectric),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(primaryAction),
                ),
                if (secondaryAction != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onSecondary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(secondaryAction),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AssignRolesScreen extends StatefulWidget {
  final String teamName;
  final List<String> players;

  const AssignRolesScreen({
    super.key,
    required this.teamName,
    required this.players,
  });

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _captain;
  String? _keeper;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.players.isNotEmpty) {
      _captain = widget.players.first;
      _keeper = widget.players.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text('${widget.teamName} - captain, keeper, substitute'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Captain'),
            Tab(text: 'Wicket keeper'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoleList(
                  title: 'Select captain',
                  selected: _captain,
                  onSelected: (name) => setState(() => _captain = name),
                ),
                _buildRoleList(
                  title: 'Select wicket keeper',
                  selected: _keeper,
                  onSelected: (name) => setState(() => _keeper = name),
                ),
              ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      SquadSelectionResult(
                        players: widget.players,
                        captain: _captain,
                        keeper: _keeper,
                      ),
                    );
                  },
                  child: const Text(
                    'Next – Match settings',
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

  Widget _buildRoleList({
    required String title,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.players.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        final name = widget.players[index - 1];
        final isSelected = name == selected;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primaryTeal : AppColors.divider,
              ),
            ),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.backgroundCardAlt,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary),
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.normal)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primaryTeal)
                : const Icon(Icons.radio_button_unchecked, color: AppColors.textSecondary),
            onTap: () => onSelected(name),
          ),
        );
      },
    );
  }
}

class SquadSelectionResult {
  final List<String> players;
  final String? captain;
  final String? keeper;

  const SquadSelectionResult({
    required this.players,
    this.captain,
    this.keeper,
  });
}

