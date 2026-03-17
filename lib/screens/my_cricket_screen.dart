import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'coming_soon_screen.dart';

class MyCricketScreen extends StatefulWidget {
  const MyCricketScreen({super.key});

  @override
  State<MyCricketScreen> createState() => _MyCricketScreenState();
}

class _MyCricketScreenState extends State<MyCricketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _matchesFilterIndex = 0;
  int _tournamentsFilterIndex = 0;
  int _teamsFilterIndex = 0;
  int _highlightsFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CricHeroes-style: Matches, Tournaments, Teams, Stats, Highlights
        Container(
          color: Colors.transparent,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primaryElectric,
            indicatorWeight: 3,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: const [
              Tab(text: 'Matches'),
              Tab(text: 'Tournaments'),
              Tab(text: 'Teams'),
              Tab(text: 'Stats'),
              Tab(text: 'Highlights'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMatchesTab(),
              _buildTournamentsTab(),
              _buildTeamsTab(),
              _buildStatsTab(),
              _buildHighlightsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartMatchRow('Want to start a match?', 'Start', () => Navigator.pushNamed(context, '/select-playing-teams')),
          const SizedBox(height: 16),
          _buildFilterPills(
            labels: const ['Your', 'Played', 'Network', 'All'],
            selectedIndex: _matchesFilterIndex,
            onSelected: (i) => setState(() => _matchesFilterIndex = i),
          ),
          const SizedBox(height: 16),
          _buildAudioLanguageRow(),
          const SizedBox(height: 20),
          _buildMatchCardPlaceholder(),
          const SizedBox(height: 24),
          _buildEmptyMatchesCTA(),
        ],
      ),
    );
  }

  Widget _buildTournamentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartMatchRow('Want to host a tournament?', 'Register', () => Navigator.pushNamed(context, '/add-tournament')),
          const SizedBox(height: 16),
          _buildFilterPills(
            labels: const ['Your', 'Participate', 'Network', 'All'],
            selectedIndex: _tournamentsFilterIndex,
            onSelected: (i) => setState(() => _tournamentsFilterIndex = i),
          ),
          const SizedBox(height: 20),
          _buildTournamentCardFull(
            bannerOverlay: "LET'S CHEER UP",
            title: 'Shaankari T-20 Cricket League Under 12',
            dates: '25 Feb, 2026 to 28 Feb, 2026',
            location: 'Hyderabad (Telangana)',
            status: 'Upcoming',
            statusTagColor: AppColors.accentYellow,
            actionLabel: 'Participate',
            bannerColor: AppColors.backgroundDark,
          ),
          const SizedBox(height: 12),
          _buildTournamentCardFull(
            bannerOverlay: 'CRICKET FEVER',
            title: 'Shenoy',
            dates: '26 Feb, 2026 to 28 Feb, 2026',
            location: 'Hyderabad (Telangana)',
            status: 'Upcoming',
            statusTagColor: AppColors.accentYellow,
            actionLabel: 'Participate',
            bannerColor: AppColors.primaryElectric,
          ),
          const SizedBox(height: 12),
          _buildTournamentCardFull(
            bannerOverlay: 'SCHOOL CRICKET CHAMPIONS',
            title: 'DA cricket League',
            dates: '12 Nov, 2022 to 12 Nov, 2022',
            location: 'Hyderabad (Telangana)',
            status: 'Past',
            statusTagColor: AppColors.textSecondary,
            actionLabel: 'Following',
            bannerColor: AppColors.backgroundDark,
          ),
          const SizedBox(height: 12),
          _buildTournamentCardFull(
            bannerOverlay: 'Corporate Cricket League by Genesis Sports',
            title: 'WillowX Corporate Cricket League',
            dates: '01 Feb, 2026 to 28 Feb, 2026',
            location: 'Hyderabad (Telangana)',
            status: 'Ongoing',
            statusTagColor: AppColors.accentSunset,
            actionLabel: 'Follow',
            bannerColor: AppColors.primaryElectric,
          ),
          const SizedBox(height: 12),
          _buildTournamentPromoCard(),
          const SizedBox(height: 12),
          _buildTournamentAdBanner(),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartMatchRow('Want to create a new team?', 'Create', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: 'Create Team')))),
          const SizedBox(height: 16),
          _buildFilterPills(
            labels: const ['Your Teams', 'Opponents', 'Following'],
            selectedIndex: _teamsFilterIndex,
            onSelected: (i) => setState(() => _teamsFilterIndex = i),
          ),
          const SizedBox(height: 16),
          _buildQuickSearchBar(),
          const SizedBox(height: 16),
          _buildTeamListTile(name: 'Nidish P', location: 'Hyderabad (Telangana)', captain: 'Akshay Reddy', hasBadge: true),
          _buildTeamListTile(name: 'Hi', location: 'Hyderabad (Telangana)', captain: 'Broo', hasBadge: false),
          _buildTeamListTile(name: 'D Team', location: 'Hyderabad (Telangana)', captain: 'Varshith Red...', hasBadge: false),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.primaryElectric.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Your stats and records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Track runs, wickets and form here.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartMatchRow('Want to live stream your match?', 'Go live', () => Navigator.pushNamed(context, '/live-stream-plan')),
          const SizedBox(height: 16),
          _buildFilterPills(
            labels: const ['Your Highlights', 'Purchased'],
            selectedIndex: _highlightsFilterIndex,
            onSelected: (i) => setState(() => _highlightsFilterIndex = i),
          ),
          const SizedBox(height: 40),
          _buildHighlightsEmptyState(),
        ],
      ),
    );
  }

  Widget _buildStartMatchRow(String prompt, String buttonLabel, VoidCallback onPressed) {
    return Row(
      children: [
        Expanded(
          child: Text(
            prompt,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ),
        Material(
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(buttonLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPills({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: selected ? AppColors.primaryTeal : AppColors.backgroundCardAlt,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.normal : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAudioLanguageRow() {
    return Row(
      children: [
        Text('Audio language:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Hindi', style: TextStyle(decoration: TextDecoration.underline, color: AppColors.textPrimary)),
        ),
        const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildMatchCardPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('Individual Match', style: TextStyle(fontSize: 11, color: AppColors.primaryTeal, fontWeight: FontWeight.normal)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Result', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('So close, yet so far! What a thrilling match!', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('#ThrillingMatch', style: TextStyle(fontSize: 12, color: AppColors.primaryTeal)),
          const SizedBox(height: 12),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryElectric.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Congratulations ADITYA 11 won the match by 1 run\nCHECK HIGHLIGHTS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMatchesCTA() {
    return Column(
      children: [
        Text(
          "Hey, you have not played any matches yet. Why don't you start one with your rival team?",
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/select-playing-teams'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Start A Match'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/all-matches'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryTeal,
                  side: const BorderSide(color: AppColors.primaryTeal),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View All Matches'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTournamentCardFull({
    required String bannerOverlay,
    required String title,
    required String dates,
    required String location,
    required String status,
    required Color statusTagColor,
    required String actionLabel,
    required Color bannerColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bannerColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(Icons.emoji_events_rounded, size: 48, color: Colors.white.withOpacity(0.2)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 8,
                child: Text(
                  bannerOverlay,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusTagColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.normal)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dates, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    Text(actionLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: AppColors.primaryTeal)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentPromoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryElectric,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sports_cricket_rounded, color: Colors.white.withOpacity(0.9), size: 24),
                const SizedBox(height: 8),
                Text(
                  'Every streamed match gets remembered',
                  style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 10),
                Material(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/live-stream-plan'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Go live →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.smartphone, color: Colors.white24, size: 64),
        ],
      ),
    );
  }

  Widget _buildTournamentAdBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentYellow.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refer & Earn Up To ₹1 Lac* Cash!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('February Referral Rush is LIVE.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Material(
                  color: AppColors.accentSunset,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Refer Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.close, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildQuickSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Quick search',
        hintStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.search, size: 22, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.backgroundWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTeamListTile({required String name, required String location, String? captain, bool hasBadge = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryElectric.withOpacity(0.2),
                child: Text(name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.primaryElectric)),
              ),
              if (hasBadge)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                  ],
                ),
                if (captain != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: AppColors.backgroundCardAlt, child: const Text('C', style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                      const SizedBox(width: 6),
                      Text(captain, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.grid_view_rounded, color: AppColors.primaryTeal, size: 22),
          if (captain != null) const SizedBox(width: 8),
          if (captain != null) Text('Members', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: AppColors.primaryTeal)),
        ],
      ),
    );
  }

  Widget _buildHighlightsEmptyState() {
    return Column(
      children: [
        Icon(Icons.videocam_off_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(
          "Sorry, you don't have any Highlights. It is available for select cities only right now.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Material(
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/live-stream-plan'),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.live_tv_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('Go live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
