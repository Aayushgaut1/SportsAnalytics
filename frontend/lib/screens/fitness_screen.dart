import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'dart:ui';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  String? _selectedSport;
  List<dynamic> _sports = [];
  List<dynamic> _players = [];
  dynamic _selectedPlayer;
  Map<String, dynamic>? _selectedPlayerVitals;
  bool _isLoading = true;
  final ScrollController _playerScrollController = ScrollController();

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
    } catch (e) {
      print('Fitness load error: $e');
    }
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
        _selectPlayerAndFetchVitals(_players.first);
      }
    } catch (e) {
      print('Fetch players error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPlayerAndFetchVitals(dynamic p) async {
    setState(() {
      _selectedPlayer = p;
      _selectedPlayerVitals = null;
    });
    try {
      final fullData = await ApiService.getPlayerFullStats(p['player_id']);
      setState(() {
        _selectedPlayerVitals = fullData['fitness'];
      });
    } catch (e) {
      print('Failed to fetch vitals: $e');
    }
  }

  void _scrollToPlayer(bool next) {
    final offset = _playerScrollController.offset;
    final target = next ? offset + 100 : offset - 100;
    _playerScrollController.animateTo(
      target.clamp(0, _playerScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSportSelector(),
                      const SizedBox(height: 40),
                      _buildAdvancedPlayerSelector(),
                      const SizedBox(height: 40),
                      if (_selectedPlayer != null) _buildVitalCommandCenter(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('VITAL ANALYTICS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 3)),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
      ),
    );
  }

  Widget _buildSportSelector() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        itemBuilder: (context, i) {
          final s = _sports[i]['sport_name'];
          final isSel = _selectedSport == s;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSport = s);
              _fetchPlayers();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSel ? appState.primaryColor : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(s.toUpperCase(), style: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white24, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedPlayerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ATHLETE REGISTRY', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Row(
              children: [
                _buildScrollArrow(false),
                const SizedBox(width: 10),
                _buildScrollArrow(true),
              ],
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 120,
          child: ListView.builder(
            controller: _playerScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _players.length,
            itemBuilder: (context, i) {
              final p = _players[i];
              final isSel = _selectedPlayer?['player_id'] == p['player_id'];
              return GestureDetector(
                onTap: () => _selectPlayerAndFetchVitals(p),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: isSel ? appState.primaryColor : Colors.white10, width: 2),
                        shape: BoxShape.circle,
                        boxShadow: isSel ? [BoxShadow(color: appState.primaryColor.withOpacity(0.3), blurRadius: 10)] : [],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://api.dicebear.com/7.x/notionists/png?seed=${p['player_id']}',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.white10, child: const Icon(Icons.person, color: Colors.white24)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 15),
                      child: Text(
                        p['name'].toString().split(' ').last.toUpperCase(),
                        style: GoogleFonts.outfit(color: isSel ? appState.primaryColor : Colors.white24, fontSize: 8, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScrollArrow(bool next) {
    return GestureDetector(
      onTap: () => _scrollToPlayer(next),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
        child: Icon(next ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: Colors.white38, size: 12),
      ),
    );
  }

  Widget _buildVitalCommandCenter() {
    return Column(
      children: [
        _buildHeroVitalCard(),
        const SizedBox(height: 30),
        if (_selectedPlayerVitals == null)
           const Center(child: CircularProgressIndicator(color: Colors.white))
        else ...[
          _buildMetricsGrid(),
          const SizedBox(height: 30),
          _buildHeartRateTrend().animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0, delay: 200.ms),
          const SizedBox(height: 30),
          _buildFitnessThresholdInfo(),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final vitals = _selectedPlayerVitals!;
    final stamina = (vitals['stamina_score'] ?? 85) / 100.0;
    final speed = (vitals['speed_score'] ?? 92) / 100.0;
    
    // Filter out internal keys and common ones we'll show specially
    final specialKeys = ['stamina_score', 'speed_score', 'injury_status', 'heart_rate_avg', 'test_date', 'player_id', 'record_id'];
    final sportMetrics = vitals.entries
        .where((e) => !specialKeys.contains(e.key))
        .toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildBiometricRing('STAMINA', stamina, appState.primaryColor)),
            const SizedBox(width: 20),
            Expanded(child: _buildBiometricRing('SPEED', speed, const Color(0xFFBC13FE))),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: sportMetrics.length,
          itemBuilder: (context, i) {
            final entry = sportMetrics[i];
            final label = entry.key.replaceAll('_', ' ').toUpperCase();
            final value = entry.value.toString();
            return _buildMiniMetricCard(label, value);
          },
        ),
      ],
    );
  }

  Widget _buildMiniMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: appState.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.bolt, color: appState.primaryColor, size: 14),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessThresholdInfo() {
    final sport = _selectedSport?.toUpperCase() ?? 'SPORT';
    String criteria = "General fitness and recovery rate.";
    if (sport.contains('CRICKET')) criteria = "High agility and anaerobic endurance.";
    else if (sport.contains('FOOTBALL')) criteria = "VO2 Max > 50 and sustained sprint capability.";
    else if (sport.contains('F1')) criteria = "G-Force tolerance and neck muscular endurance.";
    else if (sport.contains('BASKETBALL')) criteria = "Vertical explosiveness and high-intensity recovery.";
    else if (sport.contains('SWIMMING')) criteria = "High VO2 peak and muscular lactate tolerance.";
    else if (sport.contains('TENNIS')) criteria = "Side-to-side explosiveness and match-long stamina.";
    else if (sport.contains('BADMINTON')) criteria = "High-intensity interval agility and wrist reflexes.";
    else if (sport.contains('HOCKEY')) criteria = "Multi-directional speed and upper-body endurance.";
    else if (sport.contains('MOTOGP')) criteria = "Core stability and extreme cardiovascular stamina.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.02), Colors.transparent]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: appState.primaryColor, size: 16),
              const SizedBox(width: 10),
              Text('$sport FITNESS CRITERIA', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(criteria, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHeroVitalCard() {
    final isInjured = _selectedPlayerVitals?['injury_status'] == 1 || _selectedPlayerVitals?['injury_status'] == true;
    final staminaScore = _selectedPlayerVitals?['stamina_score'] ?? 100;
    final isFit = !isInjured && staminaScore >= 60;
    final statusText = _selectedPlayerVitals == null ? '...' : (isFit ? 'FIT' : 'UNFIT');
    final statusColor = isFit ? Colors.greenAccent : Colors.redAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset('assets/images/sports_bg.jpg', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: HeaderMeshPainter(statusColor.withOpacity(0.3)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedPlayer['name'].toString().toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        Text('${_selectedPlayer['nationality']} • ${_selectedPlayer['team_name']}', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                      child: Icon(Icons.monitor_heart, color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('HEIGHT', '${_selectedPlayer['height'] ?? '--'} cm'),
                    _buildMetric('WEIGHT', '${_selectedPlayer['weight'] ?? '--'} kg'),
                    _buildMetric('STATUS', statusText, color: statusColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildMetric(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildBiometricRing(String label, double val, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(value: val, strokeWidth: 10, backgroundColor: Colors.white.withOpacity(0.05), color: color, strokeCap: StrokeCap.round),
              ),
              Text('${(val * 100).toInt()}%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeartRateTrend() {
    final avgBpm = _selectedPlayerVitals?['heart_rate_avg'] ?? 72;
    final random = Random(_selectedPlayer?['player_id'] ?? 0);
    final spots = List.generate(10, (index) => FlSpot(index.toDouble(), (60 + random.nextInt(30)).toDouble()));

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('HEART RATE TREND', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text('AVG $avgBpm BPM', style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 120,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: appState.primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [appState.primaryColor.withOpacity(0.2), Colors.transparent],
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
        ),
      ),
    );
  }
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
