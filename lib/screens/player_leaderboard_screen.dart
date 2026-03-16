import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Player Leaderboard: red app bar, sport tabs (Leather/Tennis/Box cricket) in center,
/// swipeable pages; each page has role chips (Batting/Bowling/Fielding), list, promo card.
class PlayerLeaderboardScreen extends StatefulWidget {
  const PlayerLeaderboardScreen({super.key});

  @override
  State<PlayerLeaderboardScreen> createState() => _PlayerLeaderboardScreenState();
}

class _PlayerLeaderboardScreenState extends State<PlayerLeaderboardScreen> with SingleTickerProviderStateMixin {
  TabController? _sportTabController;

  static const List<String> _sports = ['Leather', 'Tennis', 'Box cricket'];

  @override
  void initState() {
    super.initState();
    _sportTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _sportTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _sportTabController;
    if (controller == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryElectric)),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Player Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 280,
              child: TabBar(
                controller: controller,
                isScrollable: false,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: _sports.map((s) => Tab(text: s)).toList(),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: const [
          _SportLeaderboardPage(sportIndex: 0, sportName: 'Leather'),
          _SportLeaderboardPage(sportIndex: 1, sportName: 'Tennis'),
          _SportLeaderboardPage(sportIndex: 2, sportName: 'Box cricket'),
        ],
      ),
    );
  }
}

/// One page per sport: role chips (Batting/Bowling/Fielding), criteria text, player list, promo card.
class _SportLeaderboardPage extends StatefulWidget {
  final int sportIndex;
  final String sportName;

  const _SportLeaderboardPage({required this.sportIndex, required this.sportName});

  @override
  State<_SportLeaderboardPage> createState() => _SportLeaderboardPageState();
}

class _SportLeaderboardPageState extends State<_SportLeaderboardPage> {
  int _roleIndex = 0; // 0 Batting, 1 Bowling, 2 Fielding
  bool _showPromoCard = true;

  static const List<String> _roles = ['Batting', 'Bowling', 'Fielding'];

  String get _criteriaText {
    if (_roleIndex == 0) return 'Most runs in India (All Time, All Overs)';
    if (_roleIndex == 1) return 'Most wickets in India (All Time, All Overs)';
    return 'Most dismissals in India (All Time, All Overs)';
  }

  String get _promoTitle {
    if (_roleIndex == 0) return 'Three 30s';
    if (_roleIndex == 1) return 'One 5-wicket haul';
    return '5 catches';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoleChips(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            _criteriaText,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: _buildFullList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_roles.length, (i) {
          final selected = _roleIndex == i;
          return Padding(
            padding: EdgeInsets.only(right: i < _roles.length - 1 ? 12 : 0),
            child: Material(
              color: selected ? AppColors.primaryTeal : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => setState(() => _roleIndex = i),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    _roles[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? Colors.white : AppColors.textPrimary,
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

  List<Widget> _buildFullList() {
    List<Widget> cards = _buildPlayerList();
    if (cards.length > 4 && _showPromoCard) {
      cards = [
        ...cards.take(4),
        _buildPromoCard(),
        ...cards.skip(4),
      ];
    }
    return cards;
  }

  List<Widget> _buildPlayerList() {
    if (_roleIndex == 0) return _battingEntries();
    if (_roleIndex == 1) return _bowlingEntries();
    return _fieldingEntries();
  }

  List<Widget> _battingEntries() {
    final list = _getBattingDataForSport(widget.sportIndex);
    return list.asMap().entries.map((e) {
      final d = e.value;
      return _playerCard(
        rank: e.key + 1,
        name: d['name'] as String,
        location: d['location'] as String,
        isPro: d['pro'] as bool,
        trailing: Text(
          'Inn: ${d['inn']} | Runs: ${d['runs']} Avg: ${d['avg']} SR: ${d['sr']}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<Widget> _bowlingEntries() {
    final list = _getBowlingDataForSport(widget.sportIndex);
    return list.asMap().entries.map((e) {
      final d = e.value;
      return _playerCard(
        rank: e.key + 1,
        name: d['name'] as String,
        location: d['location'] as String,
        isPro: d['pro'] as bool,
        trailing: Text(
          'Inn: ${d['inn']} | W: ${d['w']} Eco: ${d['eco']} SR: ${d['sr']}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<Widget> _fieldingEntries() {
    final list = _getFieldingDataForSport(widget.sportIndex);
    return list.asMap().entries.map((e) {
      final d = e.value;
      return _playerCard(
        rank: e.key + 1,
        name: d['name'] as String,
        location: d['location'] as String,
        isPro: d['pro'] as bool,
        trailing: Text(
          'Mat: ${d['mat']} | Dismissals: ${d['dismissals']} Catches: ${d['catches']} St.: ${d['st']}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getBattingDataForSport(int sportIndex) {
    const leather = [
      {'name': 'Praveen Channappa', 'location': 'Bengaluru (Ba...)', 'inn': 2071, 'runs': 80004, 'avg': 43.6, 'sr': 146.3, 'pro': false},
      {'name': 'Dk4', 'location': 'Delhi', 'inn': 2015, 'runs': 77668, 'avg': 53.68, 'sr': 156.87, 'pro': false},
      {'name': 'Vikrant Raj Salikeety', 'location': 'Hyderabad', 'inn': 1878, 'runs': 70864, 'avg': 56.11, 'sr': 177.68, 'pro': true},
      {'name': 'MD IMTEYAZ', 'location': 'Mumbai', 'inn': 2120, 'runs': 70578, 'avg': 35.47, 'sr': 194.96, 'pro': true},
      {'name': 'Vaibhav Singh', 'location': 'Pune', 'inn': 1942, 'runs': 70205, 'avg': 45.74, 'sr': 182.1, 'pro': true},
      {'name': 'Sarthak Mohapatra', 'location': 'Bengaluru (Ban...', 'inn': 2282, 'runs': 74895, 'avg': 40.4, 'sr': 188.2, 'pro': false},
      {'name': 'Ajay Bhanderi', 'location': 'Surat', 'inn': 1419, 'runs': 39236, 'avg': 36.5, 'sr': 210.2, 'pro': false},
    ];
    const tennis = [
      {'name': 'Rahul Nair', 'location': 'Chennai', 'inn': 1200, 'runs': 42000, 'avg': 38.2, 'sr': 165.0, 'pro': true},
      {'name': 'Arjun Menon', 'location': 'Kochi', 'inn': 1150, 'runs': 39800, 'avg': 40.1, 'sr': 172.3, 'pro': false},
      {'name': 'Vikram Suresh', 'location': 'Coimbatore', 'inn': 1080, 'runs': 36500, 'avg': 35.6, 'sr': 158.4, 'pro': true},
      {'name': 'Karthik Reddy', 'location': 'Hyderabad', 'inn': 980, 'runs': 33200, 'avg': 37.8, 'sr': 168.2, 'pro': false},
      {'name': 'Sandeep Kumar', 'location': 'Thiruvananthapuram', 'inn': 920, 'runs': 29800, 'avg': 34.2, 'sr': 155.1, 'pro': true},
    ];
    const boxCricket = [
      {'name': 'Ajay Bhanderi', 'location': 'Surat', 'inn': 1419, 'runs': 39236, 'avg': 36.5, 'sr': 210.2, 'pro': false},
      {'name': 'Nilesh Der', 'location': 'Surat', 'inn': 1394, 'runs': 26749, 'avg': 25.14, 'sr': 165.9, 'pro': false},
      {'name': 'Bhavesh Der', 'location': 'Surat', 'inn': 1048, 'runs': 23565, 'avg': 27.34, 'sr': 180.37, 'pro': false},
      {'name': 'Manoj Patel', 'location': 'Ahmedabad', 'inn': 990, 'runs': 22100, 'avg': 28.5, 'sr': 175.2, 'pro': true},
      {'name': 'Rakesh Shah', 'location': 'Vadodara', 'inn': 950, 'runs': 20800, 'avg': 26.1, 'sr': 169.8, 'pro': false},
    ];
    if (sportIndex == 0) return leather;
    if (sportIndex == 1) return tennis;
    return boxCricket;
  }

  List<Map<String, dynamic>> _getBowlingDataForSport(int sportIndex) {
    const leather = [
      {'name': 'Dilip', 'location': 'Delhi', 'inn': 2017, 'w': 3000, 'eco': 5.95, 'sr': 13.97, 'pro': true},
      {'name': 'Dhiraj Wadhwa', 'location': 'Gurugram (Gurgaon)', 'inn': 1892, 'w': 2850, 'eco': 6.2, 'sr': 14.1, 'pro': false},
      {'name': 'Pawan Phogat', 'location': 'New Delhi', 'inn': 1920, 'w': 2780, 'eco': 5.8, 'sr': 13.5, 'pro': true},
      {'name': 'MayaShankar Bhardwaj (MSB)', 'location': 'Noida', 'inn': 1850, 'w': 2650, 'eco': 6.0, 'sr': 14.2, 'pro': true},
      {'name': 'Ram Patil', 'location': 'Hyderabad (Telangana)', 'inn': 1780, 'w': 2520, 'eco': 6.1, 'sr': 13.8, 'pro': false},
    ];
    const tennis = [
      {'name': 'Anil Kumble', 'location': 'Bengaluru', 'inn': 1100, 'w': 1850, 'eco': 5.2, 'sr': 12.8, 'pro': true},
      {'name': 'Srinath Rao', 'location': 'Mysuru', 'inn': 1050, 'w': 1720, 'eco': 5.5, 'sr': 13.1, 'pro': false},
      {'name': 'Prasad Kumar', 'location': 'Mangaluru', 'inn': 980, 'w': 1580, 'eco': 5.8, 'sr': 13.5, 'pro': true},
    ];
    const boxCricket = [
      {'name': 'Mahesh Singh', 'location': 'Surat', 'inn': 850, 'w': 1420, 'eco': 6.3, 'sr': 14.2, 'pro': false},
      {'name': 'Ravi Joshi', 'location': 'Baroda', 'inn': 820, 'w': 1380, 'eco': 6.0, 'sr': 13.8, 'pro': true},
      {'name': 'Deepak Trivedi', 'location': 'Rajkot', 'inn': 780, 'w': 1290, 'eco': 5.9, 'sr': 13.5, 'pro': false},
    ];
    if (sportIndex == 0) return leather;
    if (sportIndex == 1) return tennis;
    return boxCricket;
  }

  List<Map<String, dynamic>> _getFieldingDataForSport(int sportIndex) {
    const leather = [
      {'name': 'Dk4', 'location': 'Delhi', 'mat': 1295, 'dismissals': 2137, 'catches': 1233, 'st': 728, 'pro': false},
      {'name': 'Nilesh Kumar Gupta', 'location': 'Lucknow', 'mat': 882, 'dismissals': 1440, 'catches': 1135, 'st': 93, 'pro': true},
      {'name': 'MayaShankar Bhardwaj (MSB)', 'location': 'Noida', 'mat': 927, 'dismissals': 1328, 'catches': 1116, 'st': 32, 'pro': true},
      {'name': 'Pulkit', 'location': 'Faridabad', 'mat': 670, 'dismissals': 1292, 'catches': 543, 'st': 676, 'pro': true},
      {'name': 'Pawan Phogat', 'location': 'New Delhi', 'mat': 690, 'dismissals': 1283, 'catches': 520, 'st': 680, 'pro': true},
    ];
    const tennis = [
      {'name': 'Rohit Kulkarni', 'location': 'Pune', 'mat': 650, 'dismissals': 980, 'catches': 620, 'st': 320, 'pro': true},
      {'name': 'Amit Deshpande', 'location': 'Nagpur', 'mat': 580, 'dismissals': 890, 'catches': 550, 'st': 280, 'pro': false},
    ];
    const boxCricket = [
      {'name': 'Harsh Mehta', 'location': 'Surat', 'mat': 720, 'dismissals': 1100, 'catches': 680, 'st': 380, 'pro': false},
      {'name': 'Yash Patel', 'location': 'Ahmedabad', 'mat': 680, 'dismissals': 1020, 'catches': 640, 'st': 340, 'pro': true},
    ];
    if (sportIndex == 0) return leather;
    if (sportIndex == 1) return tennis;
    return boxCricket;
  }

  Widget _playerCard({
    required int rank,
    required String name,
    required String location,
    required bool isPro,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.backgroundCardAlt,
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              if (isPro)
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('($location)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                trailing,
              ],
            ),
          ),
          Text(
            '$rank',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, color: AppColors.primaryElectric, size: 20),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Ready to challenge yourself?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.promoTitle),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showPromoCard = false),
                  child: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryElectric.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _roleIndex == 0 ? '3\n30s' : _roleIndex == 1 ? '1\n5W' : '5',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_promoTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text('Limited Overs', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(width: 4),
                              Icon(Icons.sports_cricket, size: 14, color: AppColors.primaryElectric),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: Text('Join', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text('Explore', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
