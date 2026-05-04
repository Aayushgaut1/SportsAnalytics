import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_state.dart';

class SportsSelectionScreen extends StatefulWidget {
  const SportsSelectionScreen({super.key});

  @override
  State<SportsSelectionScreen> createState() => _SportsSelectionScreenState();
}

class _SportsSelectionScreenState extends State<SportsSelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _sports = [
    {
      'name': 'Basketball',
      'color': const Color(0xFFFFB300),
      'desc': 'Elite court analytics and performance tracking for pro athletes.',
      'icon': Icons.sports_basketball
    },
    {
      'name': 'Football',
      'color': const Color(0xFFE91E63),
      'desc': 'Precision metrics and global squad management for the beautiful game.',
      'icon': Icons.sports_soccer
    },
    {
      'name': 'Cricket',
      'color': const Color(0xFF4CAF50),
      'desc': 'Deep statistical analysis and pitch visualization for modern legends.',
      'icon': Icons.sports_cricket
    },
    {
      'name': 'F1 Racing',
      'color': const Color(0xFF2196F3),
      'desc': 'Aerodynamic data and telemetry for high-speed performance.',
      'icon': Icons.directions_car
    },
  ];

  void _finishOnboarding(String sport) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    appState.setSportPreference(sport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  _sports[_currentPage]['color'].withOpacity(0.15),
                  Colors.black,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECT YOUR', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 5)),
                      Text('DISCIPLINE', style: GoogleFonts.outfit(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _sports.length,
                    itemBuilder: (context, index) {
                      final s = _sports[index];
                      final isSelected = _currentPage == index;
                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 300),
                        child: _buildSportCard(s),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () => _finishOnboarding(_sports[_currentPage]['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
                      decoration: BoxDecoration(
                        color: _sports[_currentPage]['color'],
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(color: _sports[_currentPage]['color'].withOpacity(0.4), blurRadius: 30, spreadRadius: 0)
                        ]
                      ),
                      child: Text('BEGIN JOURNEY', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportCard(Map<String, dynamic> sport) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Icon(sport['icon'], color: sport['color'].withOpacity(0.05), size: 300),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: sport['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Icon(sport['icon'], color: sport['color'], size: 40),
                ),
                const SizedBox(height: 30),
                Text(sport['name'].toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 15),
                Text(sport['desc'], style: GoogleFonts.outfit(color: Colors.white38, fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
