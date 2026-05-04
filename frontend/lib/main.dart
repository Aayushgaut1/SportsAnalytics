import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'screens/player_list_screen.dart';
import 'screens/performance_screen.dart';
import 'screens/fitness_screen.dart';
import 'screens/analysis_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sports_selection_screen.dart';
import 'screens/team_formation_screen.dart';
import 'state/app_state.dart';
import 'widgets/dynamic_mesh_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    appState.addListener(_update);
  }

  void _update() => setState(() {});

  void _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      appState.hasCompletedOnboarding = prefs.getBool('onboardingDone') ?? false;
    });
  }

  void _login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('onboardingDone', false);
    setState(() {
      _isLoggedIn = false;
      appState.hasCompletedOnboarding = false;
    });
  }

  @override
  void dispose() {
    appState.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SportsAlytics',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: appState.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: appState.primaryColor,
          secondary: const Color(0xFF5E60CE),
          surface: const Color(0xFF121212),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          iconTheme: IconThemeData(color: appState.primaryColor),
        ),
        useMaterial3: true,
      ),
      home: _isLoggedIn 
        ? (appState.hasCompletedOnboarding ? MainNavigation(onLogout: _logout) : const SportsSelectionScreen())
        : LoginScreen(onLoginSuccess: _login),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigation({super.key, required this.onLogout});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const PlayerListScreen(),
      const TeamFormationScreen(), 
      const PerformanceScreen(),
      const FitnessScreen(),
      const AnalysisDashboard(),
      SettingsScreen(onLogout: widget.onLogout),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          DynamicMeshBackground(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutExpo,
              switchOutCurve: Curves.easeInExpo,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: screens.elementAt(_selectedIndex),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 24,
            child: IgnorePointer(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: appState.primaryColor.withOpacity(0.3), width: 1),
                      boxShadow: [
                        BoxShadow(color: appState.primaryColor.withOpacity(0.1), blurRadius: 15, spreadRadius: 1)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPORTSALYTICS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      Text('PREMIUM PERFORMANCE HUB', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildDesignerNavBar(),
    );
  }

  Widget _buildDesignerNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, appState.translate('roster')),
                _buildNavItem(1, Icons.sports_soccer_rounded, appState.translate('formation')),
                _buildNavItem(2, Icons.analytics_rounded, appState.translate('stats')),
                _buildNavItem(3, Icons.monitor_heart_rounded, appState.translate('health')),
                _buildNavItem(4, Icons.emoji_events_rounded, appState.translate('leaders')),
                _buildNavItem(5, Icons.tune_rounded, appState.translate('settings')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? appState.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? appState.primaryColor : Colors.white24,
          size: 26,
        ),
      ),
    );
  }
}
