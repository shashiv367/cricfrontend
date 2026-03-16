import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/player_management_screen.dart';
import 'screens/looking_screen.dart';
import 'screens/my_cricket_screen.dart';
import 'screens/community_screen.dart';
import 'screens/create_match_screen.dart';
import 'screens/select_playing_teams_screen.dart';
import 'screens/matches_near_me_screen.dart';
import 'screens/add_tournament_screen.dart';
import 'screens/live_stream_plan_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/player_leaderboard_screen.dart';
import 'screens/team_leaderboard_screen.dart';
import 'screens/live_detail_screen.dart';
import 'screens/player_dashboard_screen.dart';
import 'screens/player_performance_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/cricket_profile_screen.dart';
import 'widgets/innings_logo.dart';
import 'screens/auth_screen.dart';
import 'utils/app_colors.dart';
import 'config/app_config.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/series_detail_screen.dart';
import 'screens/team_squad_detail_screen.dart';
import 'screens/more_screen.dart';
import 'widgets/innings_drawer.dart';
import 'widgets/default_page_background.dart';
import 'screens/messages_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/all_matches_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/select_ground_screen.dart';
import 'screens/select_umpire_screen.dart';
import 'screens/toss_screen.dart';
import 'screens/start_innings_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const CricbuzzApp());
}

class CricbuzzApp extends StatelessWidget {
  const CricbuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryElectric,
          secondary: AppColors.primaryElectric,
          background: AppColors.scaffoldSurface,
          surface: AppColors.scaffoldSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryElectric,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) => DefaultPageBackground(child: child),
      home: const SplashScreen(),
      routes: {
        '/live-detail': (context) => const LiveDetailScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainScreen(),
        '/dashboard': (context) => const UserDashboardScreen(),
        '/series-detail': (context) => const SeriesDetailScreen(),
        '/team-squad': (context) => const TeamSquadDetailScreen(),
        '/create-match': (context) => const CreateMatchScreen(),
        '/select-playing-teams': (context) => const SelectPlayingTeamsScreen(),
        '/toss': (context) => const TossScreen(),
        '/start-innings': (context) => const StartInningsScreen(),
        '/matches-near-me': (context) => const MatchesNearMeScreen(),
        '/add-tournament': (context) => const AddTournamentScreen(),
        '/live-stream-plan': (context) => const LiveStreamPlanScreen(),
        '/admin': (context) => const AdminPanelScreen(),
        '/players': (context) => const PlayerManagementScreen(),
        '/all-matches': (context) => const AllMatchesScreen(),
        '/my-cricket': (context) => const MyCricketScreen(),
        '/community': (context) => const CommunityScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/player-leaderboard': (context) => const PlayerLeaderboardScreen(),
        '/team-leaderboard': (context) => const TeamLeaderboardScreen(),
        '/player-dashboard': (context) => const PlayerDashboardScreen(),
        '/player-performance': (context) => const PlayerPerformanceScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/notifications-tournaments': (context) => const TournamentNotificationsScreen(),
        '/notifications-connections': (context) => const ConnectionsNotificationsScreen(),
        '/notifications-feed': (context) => const FeedNotificationsScreen(),
        '/notifications-dm': (context) => const DmNotificationsScreen(),
        '/select-ground': (context) => const SelectGroundScreen(),
        '/select-umpire': (context) => const SelectUmpireScreen(),
        '/contact': (context) => const ContactScreen(),
        '/cricket-profile': (context) => const CricketProfileScreen(),
        '/coming-soon': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return ComingSoonScreen(title: args?['title'] ?? 'Coming Soon');
        },
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shockwaveController;
  late AnimationController _lightingController;
  
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shockwaveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _shockwaveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lightingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );

    _shockwaveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shockwaveController, curve: Curves.easeOutExpo),
    );

    _controller.forward().then((_) {
      _shockwaveController.forward();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shockwaveController.dispose();
    _lightingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B), // Indigo 950
      body: Stack(
        children: [
          // 1. Dynamic Stadium Lighting Background
          AnimatedBuilder(
            animation: _lightingController,
            builder: (context, child) {
              return CustomPaint(
                painter: _StadiumLightingPainter(_lightingController.value),
                size: Size.infinite,
              );
            },
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, _shockwaveController]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 2. Shockwave Effect (Under the ball)
                    if (_shockwaveController.isAnimating || _shockwaveController.isCompleted)
                      CustomPaint(
                        painter: _ShockwavePainter(_shockwaveAnimation.value),
                        size: const Size(300, 300),
                      ),
                    
                    // 3. Speed Trails (Follows the ball entry)
                    if (_controller.value < 0.6)
                      CustomPaint(
                        painter: _SpeedTrailPainter(_controller.value),
                        size: const Size(200, 200),
                      ),

                    // 4. 3D Animated Cricket Ball
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: const _Innings3DBall(),
                            ),
                            const SizedBox(height: 40),
                            // Brand Tagline
                            const Text(
                              'ELITE • COORDINATION • PERFORMANCE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Innings3DBall extends StatelessWidget {
  const _Innings3DBall();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.3), // Cyan glow
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(10, 20),
          ),
        ],
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.8,
          colors: [
            Color(0xFFFB7185), // Rose 400 (High-key)
            Color(0xFFE11D48), // Rose 600 (Mid-tone)
            Color(0xFF4C0519), // Rose 950 (Deep Shadow)
          ],
        ),
      ),
      child: Stack(
        children: [
          // Cyan Accent Glow (Top Edge)
          Positioned(
            top: 10,
            left: 40,
            right: 40,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22D3EE).withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
          // The Seam (White lines)
          Center(
            child: Container(
              height: 4,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 1,
                  width: 150,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 1,
                  width: 150,
                  color: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ),
          // Specular Highlight for 3D effect
          Positioned(
            top: 25,
            left: 30,
            child: Container(
              width: 40,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _updateScreens();
  }

  void _updateScreens() {
    setState(() {
      _screens.clear();
      _screens.addAll([
        UserDashboardScreen(searchQuery: _searchQuery),
        LookingScreen(searchQuery: _searchQuery),
        const MyCricketScreen(),
        const CommunityScreen(),
        const MoreScreen(),
      ]);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index != 0) {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
      }
      _updateScreens();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _updateScreens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: InningsDrawer(
        onMyCricketTap: () => _onTabTapped(2),
      ),
      appBar: _buildUniversalAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryElectric,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search, weight: 900), label: 'Looking'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_cricket_outlined), activeIcon: Icon(Icons.sports_cricket), label: 'My Cricket'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_outlined), activeIcon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildUniversalAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: AppColors.primaryElectric,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
              _updateScreens();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search teams, players, tournaments...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      );
    }

    return AppBar(
      backgroundColor: AppColors.primaryElectric,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const InningsLogo(height: 30),
            const SizedBox(width: 10),
            Material(
              color: AppColors.primaryElectric,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white), 
          onPressed: () {
            setState(() {
              _isSearching = true;
              _currentIndex = 0; // Switch to Home to show results
              _updateScreens();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
      ],
    );
  }
}

class _StadiumLightingPainter extends CustomPainter {
  final double animation;
  _StadiumLightingPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4F46E5).withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Beams of light moving across the screen
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (i / 3) + (size.width * animation * 0.5)) % size.width;
      final path = Path()
        ..moveTo(x - 50, -100)
        ..lineTo(x + 50, -100)
        ..lineTo(x + 150, size.height + 100)
        ..lineTo(x - 150, size.height + 100)
        ..close();
      canvas.drawPath(path, paint..color = const Color(0xFF4F46E5).withOpacity(0.08));
    }

    // Static corner glow (Stadium floodlight vibe)
    final cornerPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF06B6D4).withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: const Offset(0, 0), radius: 300));
    canvas.drawCircle(const Offset(0, 0), 300, cornerPaint);
    
    final cornerPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF7C3AED).withOpacity(0.15), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: 400));
    canvas.drawCircle(Offset(size.width, size.height), 400, cornerPaint2);
  }

  @override
  bool shouldRepaint(covariant _StadiumLightingPainter oldDelegate) => true;
}

class _SpeedTrailPainter extends CustomPainter {
  final double animation;
  _SpeedTrailPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final random = (double seed) => (seed * 12345.67) % 1.0;

    for (var i = 0; i < 15; i++) {
      final seed = i * 1.0;
      final startOffset = Offset(
        size.width / 2 + (random(seed) - 0.5) * 100,
        size.height / 2 + (random(seed + 1) - 0.5) * 100,
      );
      
      final length = 100 * (1 - animation);
      final endOffset = Offset(
        startOffset.dx + length * 2 * (animation - 0.5),
        startOffset.dy + length * 2 * (0.5 - animation),
      );

      paint.color = const Color(0xFF06B6D4).withOpacity((1 - animation) * 0.4);
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedTrailPainter oldDelegate) => true;
}

class _ShockwavePainter extends CustomPainter {
  final double animation;
  _ShockwavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 100 + animation * 150;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * (1 - animation)
      ..color = const Color(0xFF06B6D4).withOpacity((1 - animation) * 0.5);

    canvas.drawCircle(center, radius, paint);
    
    // Outer ripple
    paint.strokeWidth = 2 * (1 - animation);
    canvas.drawCircle(center, radius + 20, paint..color = const Color(0xFF7C3AED).withOpacity((1 - animation) * 0.3));
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) => true;
}

