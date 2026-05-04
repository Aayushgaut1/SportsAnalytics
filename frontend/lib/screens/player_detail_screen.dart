import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'dart:ui';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class PlayerDetailScreen extends StatefulWidget {
  final int playerId;
  const PlayerDetailScreen({super.key, required this.playerId});
  @override State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  dynamic _player;
  Map<String, dynamic>? _playerFullStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final fullData = await ApiService.getPlayerFullStats(widget.playerId);
      setState(() { 
        _player = fullData['player']; 
        _playerFullStats = fullData['stats'];
        _isLoading = false; 
      });
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  String _getSportBg() {
    final s = _player?['sport_name']?.toString().toUpperCase() ?? 'FOOTBALL';
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
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    if (_player == null) return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text('Legend not found')));
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(child: Opacity(opacity: 0.3, child: Image.asset(_getSportBg(), fit: BoxFit.cover))),
        CustomScrollView(slivers: [
          _buildSliverHero(),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
            Text('CAREER STATISTICS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 25),
            if (_playerFullStats == null)
              const CircularProgressIndicator(color: Colors.white)
            else
              ..._buildDynamicStatsWidgets(_playerFullStats!),
            const SizedBox(height: 40),
            _buildPerformanceGraph(),
            const SizedBox(height: 100),
          ]))),
        ]),
      ]),
    );
  }

  Widget _buildSliverHero() {
    return SliverAppBar(expandedHeight: 450, pinned: true, backgroundColor: Colors.black, flexibleSpace: FlexibleSpaceBar(
      background: Stack(fit: StackFit.expand, children: [
        Image.network('https://api.dicebear.com/7.x/notionists/png?seed=${_player['player_id']}', fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset(_getSportBg(), fit: BoxFit.cover)),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)]))),
        Positioned(bottom: 30, left: 24, right: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: appState.primaryColor, borderRadius: BorderRadius.circular(5)),
            child: Text(_player['role'] ?? 'LEGEND', style: GoogleFonts.outfit(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(height: 10),
          Text(_player['name'].toString().toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          Text('${_player['nationality']} • ${_player['team_name']}', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(_player['bio'] ?? 'World-class athlete with elite performance metrics.', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
        ])),
      ]),
    ));
  }

  List<Widget> _buildDynamicStatsWidgets(Map<String, dynamic> stats) {
    if (stats.containsKey('no_data')) {
        return [Text('NO CAREER DATA AVAILABLE', style: GoogleFonts.outfit(color: Colors.white54))];
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
    else if (label.contains('CATCH') || label.contains('STUMP') || label.contains('HAULS')) iconData = Icons.sports_handball;

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
    );
  }

  Widget _buildPerformanceGraph() {
    final random = Random(widget.playerId);
    final spots = List.generate(10, (index) {
      double baseRating = 60.0 + random.nextDouble() * 30.0;
      // Add slight upward trend
      baseRating += (index * 1.5);
      if (baseRating > 100) baseRating = 100;
      return FlSpot(index.toDouble(), baseRating);
    });

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: appState.primaryColor.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PERFORMANCE TRENDS', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('FORM OVER LAST 10 MATCHES', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 30),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text('M${value.toInt()}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 9,
                minY: 40,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(colors: [appState.primaryColor.withOpacity(0.5), appState.primaryColor]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: appState.primaryColor),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [appState.primaryColor.withOpacity(0.3), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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

class TacticalDetailPainter extends CustomPainter {
  final Color color;
  TacticalDetailPainter(this.color);
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2, size.height), paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 4, Paint()..color = color);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 4, Paint()..color = color);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DetailTrendPainter extends CustomPainter {
  final Color color;
  DetailTrendPainter(this.color);
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.8, size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.1);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 8..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
