import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});
  @override State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String? _selectedSport;
  List<dynamic> _sports = [];
  List<dynamic> _players = [];
  dynamic _selectedPlayer;
  Map<String, dynamic>? _selectedPlayerFullStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final sportsData = await ApiService.getSports();
      setState(() {
        _sports = sportsData;
        _selectedSport = appState.selectedSportPreference;
      });
      _fetchPlayers();
    } catch (e) { print(e); }
  }

  Future<void> _fetchPlayers() async {
    if (_selectedSport == null) return;
    setState(() => _isLoading = true);
    try {
      final sport = _sports.firstWhere((s) => s['sport_name'].toString().toUpperCase() == _selectedSport?.toUpperCase());
      final data = await ApiService.getPlayers(sportId: sport['sport_id']);
      setState(() {
        _players = data;
        _isLoading = false;
      });
      if (_players.isNotEmpty) {
        _selectPlayerAndFetchStats(_players.first);
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  Future<void> _selectPlayerAndFetchStats(dynamic p) async {
    setState(() {
      _selectedPlayer = p;
      _selectedPlayerFullStats = null;
    });
    try {
      final fullData = await ApiService.getPlayerFullStats(p['player_id']);
      setState(() {
        _selectedPlayerFullStats = fullData['stats'];
      });
    } catch (e) {
      print('Failed to fetch full stats: $e');
    }
  }

  String _getSportBg() {
    final s = _selectedSport?.toString().toUpperCase() ?? 'FOOTBALL';
    if (s.contains('FOOTBALL')) return 'assets/images/football_bg.jpg';
    if (s.contains('CRICKET')) return 'assets/images/cricket_bg.jpg';
    if (s.contains('F1')) return 'assets/images/f1_bg.jpg';
    if (s.contains('BASKETBALL')) return 'assets/images/basketball_bg.jpg';
    if (s.contains('TENNIS')) return 'assets/images/tennis_bg.jpg';
    if (s.contains('BADMINTON')) return 'assets/images/badminton_bg.jpg';
    if (s.contains('HOCKEY')) return 'assets/images/hockey_bg.jpg';
    if (s.contains('MOTOGP')) return 'assets/images/motogp_bg.jpg';
    if (s.contains('SWIMMING')) return 'assets/images/swimming_bg.jpg';
    return 'assets/images/sports_bg.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroStatsSection(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildMiniSportSelector(),
                      const SizedBox(height: 20),
                      _buildMiniPlayerSelector(),
                      const SizedBox(height: 30),
                      if (_selectedPlayer != null) ...[
                        _buildMatchStatsSection(),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSportSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        itemBuilder: (context, i) {
          final s = _sports[i]['sport_name'];
          final isSel = _selectedSport == s;
          return GestureDetector(
            onTap: () { setState(() => _selectedSport = s); _fetchPlayers(); },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: isSel ? appState.primaryColor : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSel ? appState.primaryColor : Colors.white.withOpacity(0.2))),
                  child: Center(child: Text(s.toUpperCase(), style: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayerSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _players.length,
        itemBuilder: (context, i) {
          final p = _players[i];
          final isSel = _selectedPlayer?['player_id'] == p['player_id'];
          return GestureDetector(
            onTap: () => _selectPlayerAndFetchStats(p),
            child: Column(
              children: [
                Container(
                  width: 55, height: 55, margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: isSel ? appState.primaryColor : Colors.white24, width: isSel ? 3 : 1), shape: BoxShape.circle, boxShadow: isSel ? [BoxShadow(color: appState.primaryColor.withOpacity(0.5), blurRadius: 10)] : []),
                  child: ClipOval(child: Image.network('https://api.dicebear.com/7.x/notionists/png?seed=${p['player_id']}', fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.person, color: appState.primaryColor))),
                ),
                const SizedBox(height: 8),
                Text(p['name'].toString().split(' ').last.toUpperCase(), style: GoogleFonts.outfit(color: isSel ? appState.primaryColor : Colors.white70, fontSize: 8, fontWeight: FontWeight.w900)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroStatsSection() {
    return Container(
      height: 350, width: double.infinity,
      decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: HeaderMeshPainter(appState.primaryColor.withOpacity(0.3)))),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.5)]))),
          SafeArea(child: Padding(padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(alignment: Alignment.centerRight, child: Text('INTERACTIVE STATISTICS', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2))),
            if (_selectedPlayer != null) ...[const Spacer(), Text(_selectedPlayer['name'].toString().toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
            Text('${_selectedPlayer['nationality']} • ${_selectedPlayer['team_name']}', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 14, fontWeight: FontWeight.bold))],
          ]))),
        ],
      ),
    );
  }

  Widget _buildMatchStatsSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: [
        Text('CAREER STATISTICS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 25),
        if (_selectedPlayerFullStats == null)
          const CircularProgressIndicator(color: Colors.white)
        else
          ..._buildDynamicStatsWidgets(_selectedPlayerFullStats!),
        ]),
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  List<Widget> _buildDynamicStatsWidgets(Map<String, dynamic> stats) {
    if (stats.containsKey('no_data')) {
        return [Text('NO MATCH DATA AVAILABLE', style: GoogleFonts.outfit(color: Colors.white54))];
    }
    
    List<Widget> rows = [];
    final entries = stats.entries.toList();
    for (int i = 0; i < entries.length; i += 2) {
      final stat1 = entries[i];
      final stat2 = (i + 1 < entries.length) ? entries[i + 1] : null;
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildDynamicStatBox(stat1.key, stat1.value.toString())),
            if (stat2 != null) const SizedBox(width: 20),
            if (stat2 != null) Expanded(child: _buildDynamicStatBox(stat2.key, stat2.value.toString())) else const Spacer(),
          ],
        )
      );
      rows.add(const SizedBox(height: 15));
    }
    return rows;
  }

  Widget _buildDynamicStatBox(String key, String value) {
    final label = key.replaceAll('_', ' ').toUpperCase();
    
    IconData iconData = Icons.analytics;
    if (label.contains('RUNS') || label.contains('GOALS') || label.contains('POINTS') || label.contains('SCORE')) iconData = Icons.sports_score;
    else if (label.contains('WICKET') || label.contains('ASSIST') || label.contains('PODIUM')) iconData = Icons.stars;
    else if (label.contains('MATCH') || label.contains('GAME') || label.contains('CAPS') || label.contains('ENTERED')) iconData = Icons.calendar_month;
    else if (label.contains('AVERAGE') || label.contains('RATIO') || label.contains('ACCURACY') || label.contains('ECONOMY')) iconData = Icons.percent;
    else if (label.contains('CENTUR') || label.contains('CHAMPION') || label.contains('GOLD') || label.contains('TITLE') || label.contains('MEDAL')) iconData = Icons.emoji_events;
    else if (label.contains('CATCH') || label.contains('STUMP')) iconData = Icons.sports_handball;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appState.primaryColor.withOpacity(0.15),
            Colors.white.withOpacity(0.02),
          ]
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appState.primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: appState.primaryColor.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        children: [
          Icon(iconData, color: appState.primaryColor.withOpacity(0.8), size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, shadows: [Shadow(color: appState.primaryColor.withOpacity(0.5), blurRadius: 10)])),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1), textAlign: TextAlign.center),
        ],
      ),
    ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildRingStatCard(String label, String value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(height: 180, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: [Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)), const Spacer(),
        Stack(alignment: Alignment.center, children: [SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: 0.4, strokeWidth: 10, backgroundColor: Colors.white.withOpacity(0.05), color: color)), Text(value, style: GoogleFonts.outfit(color: Colors.white))]),
        const Spacer()]),
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTacticalPositionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(height: 180, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: [Text('AVERAGE POSITIONS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10)), const Spacer(),
        Expanded(child: CustomPaint(size: Size.infinite, painter: TacticalMapPainter(appState.primaryColor)))]),
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTrendAnalysisSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(height: 180, width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Stack(children: [CustomPaint(size: Size.infinite, painter: TrendGraphPainter([const Color(0xFF6C63FF), const Color(0xFF00E5FF)])),
        Positioned(bottom: 0, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ['1st', '2nd', '3rd', '4th', '5th'].map((e) => Text(e, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 8))).toList()))]),
        ),
      ),
    ).animate().fade(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class TacticalMapPainter extends CustomPainter {
  final Color primaryColor;
  TacticalMapPainter(this.primaryColor);
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2, size.height), paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 4, Paint()..color = primaryColor);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 4, Paint()..color = primaryColor);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrendGraphPainter extends CustomPainter {
  final List<Color> colors;
  TrendGraphPainter(this.colors);
  @override void paint(Canvas canvas, Size size) {
    for (var color in colors) {
      final paint = Paint()..color = color.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 3;
      final path = Path();
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.6);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.2, size.width, size.height * 0.4);
      canvas.drawPath(path, paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeaderMeshPainter extends CustomPainter {
  final Color color;
  HeaderMeshPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
