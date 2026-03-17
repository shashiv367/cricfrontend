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
          const Expanded(
            child: Center(
              child: Text(
                'No matches to show yet',
                style: TextStyle(color: AppColors.textSecondary),
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
                      fontWeight: FontWeight.normal,
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
                labelStyle: const TextStyle(fontWeight: FontWeight.normal),
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
