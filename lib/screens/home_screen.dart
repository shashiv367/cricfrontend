import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/match_card.dart';
import '../widgets/featured_match_card.dart';
import 'team_screen.dart';
import 'ranking_screen.dart';
import 'user_matches_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Custom Header
          _buildHeader(),
          
          // Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Premier League',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Featured Match (Live)
                  const FeaturedMatchCard(
                    league: 'Premier League',
                    team1: 'Liverpool',
                    team2: 'Man Utd',
                    score1: 0,
                    score2: 0,
                    time: '27:33',
                    question: 'Will the keeper of Liverpool stop any goals?',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Match List
                  MatchCard(
                    team1: 'Liverpool',
                    team2: 'Chelsea',
                    score1: 2,
                    score2: 0,
                    isLive: false,
                    matchStatus: '22 Apr 17:20',
                    subtitle: 'Home will win',
                    subtitleColor: AppColors.accentGreen,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  MatchCard(
                    team1: 'Tottenham',
                    team2: 'Man City',
                    score1: 0,
                    score2: 1,
                     isLive: false,
                    matchStatus: '16 Apr 14:00',
                    subtitle: 'Guest will win',
                    subtitleColor: AppColors.accentRed,
                     onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  MatchCard(
                    team1: 'Chelsea',
                    team2: 'Man Utd',
                    score1: 0,
                    score2: 0,
                     isLive: false,
                    matchStatus: '3 Apr 10:30',
                    subtitle: 'Draw',
                    subtitleColor: AppColors.accentYellow,
                     onTap: () {},
                  ),
                   const SizedBox(height: 16),
                  
                  MatchCard(
                    team1: 'Tottenham',
                    team2: 'Chelsea',
                    score1: 1,
                    score2: 2,
                     isLive: false,
                    matchStatus: '28 Mar 20:00',
                    subtitle: 'Guest will win',
                    subtitleColor: AppColors.accentGreen,
                     onTap: () {},
                  ),
                  
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5B21B6), // Deep Purple
            Color(0xFF7C3AED), // Lighter Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              // Top Bar: Back, Title, Search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                       // Handle back if needed, or maybe Menu
                    },
                  ),
                  const Text(
                    'Soccer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentYellow,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'World Cup'),
                ],
                isScrollable: true,
                dividerColor: Colors.transparent, // Remove default divider
              ),
            ],
          ),
        ),
      ),
    );
  }
}
