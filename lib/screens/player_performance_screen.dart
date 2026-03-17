import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/supabase_client.dart';

/// My Performance — player profile style: green header, INFO / BATTING / BOWLING / CAREER / NEWS tabs.
class PlayerPerformanceScreen extends StatefulWidget {
  const PlayerPerformanceScreen({super.key});

  @override
  State<PlayerPerformanceScreen> createState() => _PlayerPerformanceScreenState();
}

class _PlayerPerformanceScreenState extends State<PlayerPerformanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _playerName = 'Shashi Vardhan';
  int _iccRankingIndex = 0; // 0 Batting, 1 Bowling, 2 All-Rounder

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPlayerName();
  }

  Future<void> _loadPlayerName() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final name = user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'Shashi Vardhan';
      if (mounted) setState(() => _playerName = name.toString());
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
      body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primaryElectric,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26), onPressed: () => Navigator.maybePop(context)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.share, color: Colors.white, size: 24), onPressed: () {}),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Text(
                            _playerName.isNotEmpty ? _playerName.substring(0, 1).toUpperCase() : 'P',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.normal),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _playerName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 22),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text('India', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: AppColors.primaryElectric,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                      tabs: const [
                        Tab(text: 'INFO'),
                        Tab(text: 'BATTING'),
                        Tab(text: 'BOWLING'),
                        Tab(text: 'CAREER'),
                        Tab(text: 'NEWS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildBattingTab(),
                _buildBowlingTab(),
                _buildCareerTab(),
                _buildNewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PERSONAL INFORMATION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _buildCard([
            _row('Born', 'July 18, 1996 (29 years)'),
            _row('Birth Place', 'Bombay (now Mumbai), Maharashtra'),
            _row('Full Name', _playerName),
            _row('Role', 'Batsman'),
            _row('Batting Style', 'Right Handed Bat'),
            _row('Bowling Style', 'Right-arm medium'),
          ]),
          const SizedBox(height: 24),
          const Text('RECENT FORM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          const Text('BATTING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _buildRecentFormTable(
            headers: const ['SCORE', 'OPPN.', 'FORMAT', 'DATE'],
            rows: [
              ['82(55)', 'AUSW', 'T20I', '21 Feb 26'],
              ['31(24)', 'AUSW', 'T20I', '19 Feb 26'],
              ['16*(17)', 'AUSW', 'T20I', '15 Feb 26'],
              ['87(41)', 'DCW', 'T20', '05 Feb 26'],
              ['54*(27)', 'UPW', 'T20', '29 Jan 26'],
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Text('View all matches >', style: TextStyle(fontSize: 14, color: AppColors.primaryElectric, fontWeight: FontWeight.normal)),
          ),
          const SizedBox(height: 24),
          const Text('TEAMS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundCardAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              'Bengaluru Women, India A Women',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          const Text('ICC RANKINGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              _iccChip('Batting', 0),
              const SizedBox(width: 8),
              _iccChip('Bowling', 1),
              const SizedBox(width: 8),
              _iccChip('All-Rounder', 2),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentFormTable(
            headers: const ['FORMAT', 'CURRENT RANK', 'BEST RANK'],
            rows: [
              ['Test', '-', '-'],
              ['ODI', '2', '1'],
              ['T20', '3', '2'],
            ],
          ),
          const SizedBox(height: 24),
          const Text('SUMMARY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(
            'Started cricket at school and soon became the second Indian cricketer to feature in a foreign T20 league, scoring a World Cup century and a double ton in domestic cricket. Signed up for trials at nine, left-handed with the bat despite being right-handed. Made it to Maharashtra Under-19 and then the senior team, debuting with 155 against Saurashtra. Scored a fifty on Test debut in 2014. Played World T20 and WBBL before an ACL tear. Took part in ECB\'s Women\'s Cricket League. Became India\'s youngest T20I captain at 22, leading a 3-match series against England in 2019, and was named International Woman Cricketer of the Year. Scored a maiden Test century in 2021. Won silver at the 2022 Commonwealth Games and gold at the 2023 Asian Games.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBattingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Career', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
              const Spacer(),
              Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatsTable(
            columnHeaders: const ['TEST', 'ODI', 'T20', 'WPL'],
            rows: [
              ['Batting', '', '', '', ''],
              ['Matches', '7', '82', '123', '25'],
              ['Innings', '12', '80', '118', '24'],
              ['Runs', '629', '3076', '3214', '892'],
              ['Balls', '1024', '3421', '2580', '612'],
              ['Highest', '127', '135', '112', '96'],
              ['Average', '57.18', '43.32', '29.48', '40.55'],
              ['SR', '61.43', '89.91', '124.57', '145.75'],
              ['Not Out', '1', '9', '9', '2'],
              ['Fours', '78', '342', '368', '98'],
              ['Sixes', '2', '28', '52', '24'],
              ['Ducks', '0', '2', '4', '0'],
              ['50s', '4', '26', '18', '6'],
              ['100s', '2', '7', '2', '0'],
              ['200s', '0', '0', '0', '0'],
              ['300s', '0', '0', '0', '0'],
              ['400s', '0', '0', '0', '0'],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBowlingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Career', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
              const Spacer(),
              Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatsTable(
            columnHeaders: const ['TEST', 'ODI', 'T20', 'WPL'],
            rows: [
              ['Bowling', '', '', '', ''],
              ['Balls', '12', '36', '0', '3'],
              ['Runs', '8', '47', '0', '9'],
              ['Maidens', '0', '0', '0', '0'],
              ['Wickets', '0', '1', '0', '0'],
              ['Avg', '0.0', '47.0', '0.0', '0.0'],
              ['Eco', '4', '7.83', '0', '0'],
              ['SR', '0.0', '36.0', '0.0', '0.0'],
              ['BBI', '0/8', '1/13', '-/-', '0/9'],
              ['BBM', '0/8', '1/13', '-/-', '0/9'],
              ['4w', '0', '0', '0', '0'],
              ['5w', '0', '0', '0', '0'],
              ['10w', '0', '0', '0', '0'],
            ],
          ),
          const SizedBox(height: 24),
          const Text('BOWLING', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _buildRecentFormTable(
            headers: const ['WICKETS', 'OPPN.', 'FORMAT', 'DATE'],
            rows: [
              ['0-12', 'RSAW', 'ODI', '07 May 25'],
              ['0-12', 'AUSW', 'ODI', '08 Dec 24'],
              ['0-8 & DNB', 'RSAW', 'Test', '28 Jun 24'],
              ['0-10', 'RSAW', 'ODI', '23 Jun 24'],
              ['1-13', 'RSAW', 'ODI', '19 Jun 24'],
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Text('View all matches >', style: TextStyle(fontSize: 14, color: AppColors.primaryElectric, fontWeight: FontWeight.normal)),
          ),
          const SizedBox(height: 24),
          const Text('TEAMS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(
            'India Women, Brisbane Heat Women, Trailblazers, Western Storm, Hobart Hurricanes Women, India B Women, Southern Brave Women, Sydney Thunder Women, Royal Challengers Bengaluru Women, India A Women',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          const Text('ICC RANKINGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              _iccChip('Batting', 0),
              const SizedBox(width: 8),
              _iccChip('Bowling', 1),
              const SizedBox(width: 8),
              _iccChip('All-Rounder', 2),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentFormTable(
            headers: const ['FORMAT', 'CURRENT RANK', 'BEST RANK'],
            rows: [
              ['Test', '-', '-'],
              ['ODI', '2', '1'],
              ['T20', '3', '2'],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _iccChip(String label, int index) {
    final selected = _iccRankingIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _iccRankingIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryElectric : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryElectric),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: selected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildCareerTab() {
    final formats = [
      {'format': 'T20', 'debut': 'vs Bangladesh Women', 'debutDate': '2013-04-05', 'debutVenue': 'Reliance Stadium', 'last': 'vs Australia Women', 'lastDate': '2026-02-21', 'lastVenue': 'Adelaide Oval'},
      {'format': 'TEST', 'debut': 'vs England Women', 'debutDate': '2014-08-13', 'debutVenue': "Sir Paul Getty's Ground", 'last': 'vs South Africa Women', 'lastDate': '2024-06-28', 'lastVenue': 'MA Chidambaram Stadium'},
      {'format': 'ODI', 'debut': 'vs Bangladesh Women', 'debutDate': '2013-04-10', 'debutVenue': 'Narendra Modi Stadium', 'last': 'vs South Africa Women', 'lastDate': '2025-11-02', 'lastVenue': 'Dr DY Patil Sports Academy'},
      {'format': 'IPL', 'debut': 'Not played', 'debutDate': '', 'debutVenue': '', 'last': 'Not played', 'lastDate': '', 'lastVenue': ''},
      {'format': 'CL', 'debut': 'Not played', 'debutDate': '', 'debutVenue': '', 'last': 'Not played', 'lastDate': '', 'lastVenue': ''},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 38, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...formats.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f['format']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _careerRow('Debut', f['debut']!, f['debutDate']!, f['debutVenue']!),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 12),
                      _careerRow('Last Played', f['last']!, f['lastDate']!, f['lastVenue']!),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _careerRow(String label, String opponent, String date, String venue) {
    final isNotPlayed = opponent == 'Not played';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        if (isNotPlayed)
          GestureDetector(
            onTap: () {},
            child: Text(opponent, style: const TextStyle(fontSize: 14, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(onTap: () {}, child: Text(opponent, style: const TextStyle(fontSize: 14, color: Color(0xFF2563EB), fontWeight: FontWeight.w500))),
              if (date.isNotEmpty) ...[
                const SizedBox(height: 2),
                GestureDetector(onTap: () {}, child: Text(date, style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB)))),
              ],
              if (venue.isNotEmpty) ...[
                const SizedBox(height: 2),
                GestureDetector(onTap: () {}, child: Text(venue, style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB)))),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildNewsTab() {
    final news = [
      {'headline': 'Shreyanka shines as India take lead in multi-format series', 'time': '2 days ago', 'summary': 'Fifties from Smriti Mandhana and Jemimah Rodrigues helped India post 176 before the bowlers derailed Australia\'s chase in the PowerPlay'},
      {'headline': 'How Mandhana bent the 204 chase to her will', 'time': 'Fri, 06 Feb 2026', 'summary': 'Even through illness, Smriti Mandhana\'s clarity and control defined a record chase in the final against DC'},
      {'headline': "Stats: A final of records and RCB's dominance", 'time': 'Thu, 05 Feb 2026', 'summary': 'Key numbers from the Women\'s Premier League 2026 final between RCB and Delhi Capitals'},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 20),
      child: Column(
        children: [
          ...news.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCardAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.image_outlined, size: 36, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n['headline']!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(n['time']!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(
                            n['summary']!,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
          const SizedBox(height: 28),
          _buildPanBaharAd(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPanBaharAd() {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text('Ad', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFFFD54F), const Color(0xFFFFB300), const Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('INDIA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey[800])),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(6)),
                      child: Text('vs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.grey[800])),
                    ),
                    const SizedBox(width: 14),
                    Text('ZIM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey[800])),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('PAN BAHAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: AppColors.textPrimary, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('PEHCHAN KAMYABI KI CONTEST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.grey[800])),
                const SizedBox(height: 20),
                Material(
                  color: AppColors.accentSunset,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Text('CLICK TO ENTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('WIN TEES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.grey[800])),
                    Icon(Icons.info_outline, size: 18, color: Colors.grey[700]),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('T&C', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.card_giftcard, size: 24, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pan Bahar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('The Heritage Pan Masala - Pehchan Ka...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Material(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Text('Know More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              e.value,
              if (!isLast) const Divider(height: 24, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
      ],
    );
  }

  Widget _buildRecentFormTable({required List<String> headers, required List<List<String>> rows}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryElectric.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: headers.asMap().entries.map((e) {
                final flex = e.key == 0 ? 2 : 1;
                return Expanded(
                  flex: flex,
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xFF166534)),
                  ),
                );
              }).toList(),
            ),
          ),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                ...row.asMap().entries.map((e) {
                  final flex = e.key == 0 ? 2 : 1;
                  return Expanded(
                    flex: flex,
                    child: Text(
                      e.value,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  );
                }),
                const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatsTable({required List<String> columnHeaders, required List<List<String>> rows}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primaryElectric.withOpacity(0.12)),
          headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
          dataTextStyle: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          columnSpacing: 24,
          columns: [
            const DataColumn(label: Text('')),
            ...columnHeaders.map((h) => DataColumn(label: Text(h))),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                DataCell(Text(row[0], style: const TextStyle(fontWeight: FontWeight.w500))),
                ...row.skip(1).map((c) => DataCell(Text(c))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
